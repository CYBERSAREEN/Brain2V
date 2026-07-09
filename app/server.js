#!/usr/bin/env node
/**
 * Brain2V Dashboard — zero-dependency Node server.
 * Reads your Obsidian vault, computes live metrics, builds the wikilink graph,
 * and reports the status of every Brain2V service (Graphify, n8n, plugins, MCP).
 *
 * No npm install needed. Node 18+ only.
 *   node app/server.js            (config from app/config.json)
 */
import http from 'node:http'
import fs from 'node:fs'
import path from 'node:path'
import { execSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

function loadConfig() {
  const p = path.join(__dirname, 'config.json')
  if (!fs.existsSync(p)) {
    console.error('app/config.json not found — copy config.example.json and set vaultPath.')
    process.exit(1)
  }
  const cfg = JSON.parse(fs.readFileSync(p, 'utf8'))
  if (!cfg.vaultPath || !fs.existsSync(cfg.vaultPath)) {
    console.error(`vaultPath "${cfg.vaultPath}" does not exist — fix app/config.json.`)
    process.exit(1)
  }
  return { port: 7180, ...cfg }
}

const cfg = loadConfig()
const IGNORED_DIRS = new Set(['.obsidian', '.git', '.trash', '.obs-index', 'node_modules'])

function walkVault(dir, files = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.') || IGNORED_DIRS.has(entry.name)) continue
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walkVault(full, files)
    else if (entry.name.endsWith('.md')) files.push(full)
  }
  return files
}

let cache = { at: 0, data: null }

function scanVault() {
  if (Date.now() - cache.at < 10_000 && cache.data) return cache.data

  const files = walkVault(cfg.vaultPath)
  const notes = []
  const nodeIndex = new Map() // note name -> node id
  const links = []
  let totalWords = 0
  const folders = {}
  const tagCounts = {}

  for (const file of files) {
    const rel = path.relative(cfg.vaultPath, file)
    const name = path.basename(file, '.md')
    const folder = rel.includes(path.sep) ? rel.split(path.sep)[0] : '(root)'
    const raw = fs.readFileSync(file, 'utf8')
    const words = (raw.match(/\S+/g) || []).length
    const stat = fs.statSync(file)
    totalWords += words
    folders[folder] = (folders[folder] || 0) + 1

    for (const m of raw.matchAll(/(?:^|\s)tags:\s*\[([^\]]*)\]/gm)) {
      for (const t of m[1].split(',').map((s) => s.trim()).filter(Boolean)) {
        tagCounts[t] = (tagCounts[t] || 0) + 1
      }
    }

    const outLinks = [...raw.matchAll(/\[\[([^\]|#]+)(?:[|#][^\]]*)?\]\]/g)].map((m) =>
      m[1].trim().split('/').pop()
    )
    notes.push({ name, rel, folder, words, mtime: stat.mtimeMs, outLinks })
    if (!nodeIndex.has(name)) nodeIndex.set(name, nodeIndex.size)
  }

  for (const n of notes) {
    for (const target of n.outLinks) {
      if (nodeIndex.has(target)) links.push([nodeIndex.get(n.name), nodeIndex.get(target)])
    }
  }

  const degree = new Array(nodeIndex.size).fill(0)
  for (const [a, b] of links) { degree[a]++; degree[b]++ }

  const nodes = [...nodeIndex.entries()].map(([name, id]) => {
    const note = notes.find((n) => n.name === name)
    return { id, name, folder: note?.folder || '?', degree: degree[id] }
  })

  const recent = [...notes].sort((a, b) => b.mtime - a.mtime).slice(0, 12)
    .map((n) => ({ name: n.name, rel: n.rel, mtime: n.mtime, words: n.words }))

  const countEntries = (folderName, pattern) => {
    const f = notes.filter((n) => n.folder === folderName)
    let count = 0
    for (const n of f) {
      const raw = fs.readFileSync(path.join(cfg.vaultPath, n.rel), 'utf8')
      count += (raw.match(pattern) || []).length
    }
    return count
  }

  const data = {
    generatedAt: new Date().toISOString(),
    vaultPath: cfg.vaultPath,
    totals: {
      notes: notes.length,
      words: totalWords,
      links: links.length,
      folders: Object.keys(folders).length,
      learnings: countEntries('Learnings', /^### /gm),
      mistakes: countEntries('Mistakes', /^### /gm),
    },
    folders,
    topTags: Object.entries(tagCounts).sort((a, b) => b[1] - a[1]).slice(0, 12),
    godNodes: [...nodes].sort((a, b) => b.degree - a.degree).slice(0, 8),
    recent,
    graph: { nodes, links },
  }
  cache = { at: Date.now(), data }
  return data
}

function cmdExists(cmd) {
  try { execSync(`command -v ${cmd}`, { stdio: 'pipe' }); return true } catch { return false }
}

async function serviceStatus() {
  const status = {
    graphify: { installed: cmdExists('graphify'), note: 'knowledge-graph engine (graphify.net)' },
    n8n: { installed: cmdExists('n8n'), running: false, note: 'local automation (:5678)' },
    claude: { installed: cmdExists('claude'), note: 'Claude Code CLI' },
    obsidian: { installed: fs.existsSync(path.join(cfg.vaultPath, '.obsidian')), note: 'vault detected' },
  }
  try {
    const res = await fetch('http://localhost:5678/healthz', { signal: AbortSignal.timeout(4000) })
    status.n8n.running = res.ok
  } catch { /* not running */ }
  const graphifyOut = path.join(cfg.vaultPath, 'graphify-out', 'graph.json')
  status.graphify.graphBuilt = fs.existsSync(graphifyOut)
  return status
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost')
  try {
    if (url.pathname === '/api/vault') {
      res.writeHead(200, { 'Content-Type': 'application/json' })
      res.end(JSON.stringify(scanVault()))
    } else if (url.pathname === '/api/status') {
      res.writeHead(200, { 'Content-Type': 'application/json' })
      res.end(JSON.stringify(await serviceStatus()))
    } else if (url.pathname === '/graphify' ) {
      const p = path.join(cfg.vaultPath, 'graphify-out', 'graph.html')
      if (fs.existsSync(p)) {
        res.writeHead(200, { 'Content-Type': 'text/html' })
        res.end(fs.readFileSync(p))
      } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' })
        res.end('Graphify graph not built yet — run: graphify <vault-path>')
      }
    } else if (url.pathname === '/' || url.pathname === '/index.html') {
      res.writeHead(200, { 'Content-Type': 'text/html' })
      res.end(fs.readFileSync(path.join(__dirname, 'index.html')))
    } else {
      res.writeHead(404); res.end('not found')
    }
  } catch (err) {
    console.error(err)
    res.writeHead(500, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ error: String(err.message || err) }))
  }
})

server.listen(cfg.port, () => {
  console.log(`Brain2V dashboard → http://localhost:${cfg.port}  (vault: ${cfg.vaultPath})`)
})
