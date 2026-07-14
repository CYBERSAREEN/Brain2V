# MCP integration — giving the vault a shape

BrainV2 wires two engines into the vault so the "second brain" has a live, queryable
shape instead of being a pile of notes:

## Graphify (semantic graph)

- **What it is:** an MIT-licensed knowledge-graph builder (graphify.net). It parses the
  vault (Markdown, PDFs, diagrams), builds a NetworkX graph, runs Leiden community
  detection, and finds "god nodes" (highest-degree hubs) and "surprise" cross-domain
  edges — no vector store, no embeddings.
- **Install:** `pip install graphifyy && graphify install` (done by
  `setup/setup-services.sh`).
- **Build the graph:** `graphify <vaultPath>` → outputs land in `<vaultPath>/graphify-out/`
  (`graph.html`, `graph.json`, `GRAPH_REPORT.md`).
- **MCP mode:** Graphify ships `serve.py` (MCP-protocol service). To expose it to Claude
  Code as an MCP server, register the graphify serve command in Claude's MCP config; the
  organiser then queries the graph via `/graphify query`, `/graphify path`,
  `/graphify explain` instead of re-reading raw notes (≈70× fewer tokens per query).
- **In the dashboard:** the built `graph.html` is served at `/graphify`; the dashboard's
  own force-directed canvas shows the wikilink graph (a fast, dependency-free preview),
  while Graphify's is the deep semantic one.

## n8n (local automation)

- **What it is:** self-hosted workflow automation. Every user runs it locally
  (`n8n start` → `http://localhost:5678`) — no cloud, data stays on the machine.
- **Role in BrainV2:** the automation layer. Workflows the user builds (capture-to-vault
  webhooks, scheduled digests, cross-service triggers) are recorded via `/obs-n8n` so
  `/obs-organiser` can route future "automate X" requests to an existing workflow instead
  of rebuilding it.
- **Dashboard tile:** the dashboard polls `:5678/healthz` and shows n8n as live/stopped.

## The loop

Obsidian (notes) → Graphify (shape + semantic queries) → Claude Code (`/obs-*` skills
routing) → n8n (automation on triggers) → back into Obsidian (new notes/learnings). The
dashboard at `:7180` is the window onto all of it: metrics, graph, service health.
