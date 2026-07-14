# BrainV2

**A second-brain skill system for Claude Code.** BrainV2 turns a plain Obsidian vault
into a self-organizing knowledge system that Claude Code drives as one coherent brain —
routing each request to the right skill, fetching context in O(1) via a hash index
instead of scanning the whole vault, and closing the loop on every task by recording
learnings and mistakes so repeat work gets faster and cheaper.

> **This repository contains the skill *system* only** — the command definitions, the
> index/linking protocols, the hook configuration, and the docs. It contains **no vault
> content and no credentials.** Your actual notes (and anything sensitive) stay on your
> machine and are never part of this repo. See [Security](#security).

## What's in here

```
BrainV2/
├── commands/      # the /obs-* skills + /trace (install into ~/.claude/commands/)
├── knowledge/     # shared protocols the skills rely on (install into ~/.claude/knowledge/)
│   ├── obs-index-protocol.md     # the two-layer fast index (hash + filesystem symlinks)
│   └── obs-linking-protocol.md   # how notes cross-link into one graph
├── hooks/         # settings.hooks.json — the auto-trigger hook block (merge into ~/.claude/settings.json)
├── docs/          # architecture, trigger points, efficiency notes
└── install.sh     # copies the above into your ~/.claude/ (with confirmation)
```

## The skills

| Skill | Does |
|---|---|
| `/obs-organiser` | The orchestrator brain — routes requests, initializes the fast index, drives the request→execute→learn→feedback loop. Start here. |
| `/obs-guide` | Briefs you on what's complete / incomplete / what to start next. |
| `/obs-list` | Detailed inventory of the whole system, built from the fast index (not a scan). |
| `/obs-learn` | Captures a reusable lesson, dated. |
| `/obs-learn-cyber` | Learns cybersecurity + AI specifically — PDFs, courses, MCP concepts, "what I did." |
| `/obs-mistakes` | Logs an error + its fix so it's never repeated. |
| `/obs-connect` | Bridges two topics via the link graph. |
| `/obs-distil` | "Remember this, minimally" — stores only the required essence of a PDF/brief/dump (with a source pointer), so future reads cost far fewer tokens. |
| `/obs-requests` | Researches this session's ambiguous prompts at session end, files a refined "what you meant" version, and — as history builds — states the inferred requirement and asks a fast permission check before applying it to a similar future prompt. |
| `/obs-tokenguard` | Reviews this session's tool calls for approximate token cost and suggests cheaper alternatives. Paired with a real-time `PreToolUse` hook that nudges (never blocks) on large file reads. |
| `/obs-closeday` | End-of-day log: progress, ideas, carryover. |
| `/obs-retain-context` | Snapshots the session before context compacts. |
| `/obs-personality` | Stores an identity/credential profile **locally** (never in this repo). |
| `/obs-pentest` | Scope-gated pentest engagement logger + runner. |
| `/obs-context-code`, `/obs-understanding`, `/trace` | Session context load, workflow learning, and idea-evolution timelines. |

## How it works (short version)

1. **Fast index, not scans.** Every note is registered in a two-layer index: a hash map
   (`date|time|day|label → note`) for exact O(1) lookup, and a symlink tree
   (`by-date/`, `by-day/`, `by-label/`) so "everything from Friday" or "everything
   tagged pentest" is a plain filesystem `ls` — as fast as the OS finds a file. See
   `knowledge/obs-index-protocol.md`.
2. **One graph, not silos.** Every note cross-links to same-day and subject-related notes
   and carries a shared `#obs` tag, so the vault reads as one connected brain. See
   `knowledge/obs-linking-protocol.md`.
3. **The loop closes itself.** Hooks nudge the model to log a mistake+fix when a tool
   fails, offer a `/obs-connect` when a new cross-section note appears, brief you at
   session start, snapshot before compaction, and wrap up at session end. See
   `docs/trigger-points.md`.
4. **Distil, don't dump.** Large inputs (a whole PDF, an over-explained brief) are stored
   as only their *required* essence plus a pointer to the untouched source — a fraction of
   the tokens on every future read, with nothing actually lost. See
   `knowledge/obs-distillation-protocol.md` and `/obs-distil`.
5. **Reuse makes it cheaper.** Because context resolves through the index and prior
   solutions/templates/learnings are persisted, the *second* similar project reuses the
   first instead of re-deriving it. That reuse — not magic — is what drives work down in
   time and tokens over time. See `docs/efficiency.md` for an honest account of what is
   and isn't automatic.

## Full Manual

[`docs/manual/BrainV2-Manual.pdf`](./docs/manual/BrainV2-Manual.pdf) — every skill above,
documented in detail with usage syntax and a worked example, plus an "Honest limit" note
wherever a skill has a genuine approximation or constraint. Source: `docs/manual/MANUAL.html`.

## Install

```bash
./install.sh
```

The script copies `commands/` and `knowledge/` into `~/.claude/`, and prints the hook
block from `hooks/settings.hooks.json` for you to merge into `~/.claude/settings.json`
(it will not blindly overwrite your settings). **Before installing, open
`hooks/settings.hooks.json` and change the vault path in the `PostToolUse` `if:`
conditions** (`.../ObsidianVaults/AgencyMemory/*`) to your own vault path.

## Security

BrainV2 is designed to be public-safe:
- **No vault content ships here** — only skill definitions and protocols.
- **No credentials ship here.** `/obs-personality` stores secrets *locally* in your vault
  by design; those notes and any secrets file are excluded by `.gitignore` and must
  never be added to this repo.
- The `.gitignore` defensively excludes `.env`, `*.secret`, `.personality.txt`,
  `.secrets/`, `.obs-index/`, and common vault folders, so an accidental `git add -A`
  from the wrong directory can't sweep secrets in. **Still run a secret scan before every
  push.**

## License

MIT — see [LICENSE](./LICENSE).

---

## BrainV2 as an app (v2)

Beyond the skill system, BrainV2 ships a local **application layer** — Claude Code
installs and drives it for you:

- **`app/`** — a zero-dependency Node dashboard (`node app/server.js` → `http://localhost:7180`).
  Reads your vault live: note/word/link counts, learnings & mistakes logged, folder
  breakdown, a force-directed wikilink graph, "god nodes", recent activity, and a
  **services panel** showing Graphify / n8n / Claude / Obsidian status at a glance.
- **Graphify** ([graphify.net](https://graphify.net), MIT) — the semantic
  knowledge-graph engine that gives the vault a queryable *shape*. Built graph is served
  at `/graphify`. See `knowledge/obs-mcp-integration.md`.
- **n8n** — self-hosted, **local** automation (`n8n start` → `:5678`). Every user runs it
  on their own machine; workflows are captured via `/obs-n8n` and routed by the organiser.
- **Plugin marketplaces** (`plugins.json`) — superpowers, claude-skills, marketing-skills,
  social-media-skills. Auto-added at setup; `/obs-organiser` decides when each is used per
  `knowledge/obs-plugin-routing.md`. (`gstack` is deliberately not included — it has no
  `.claude-plugin/marketplace.json`, so it isn't installable this way; see `plugins.json`.)

### Setup (Claude drives this — see `CLAUDE.md`)

```bash
./install.sh              # skills + protocols + hooks
./setup/setup-services.sh # Graphify, n8n, plugin marketplaces, dashboard config
# set app/config.json -> vaultPath, then:
graphify <your-vault>     # build the semantic graph
node app/server.js        # dashboard  -> :7180
n8n start                 # automation -> :5678
```

## Acknowledgements & upstream tools

BrainV2 stands on open-source work by these projects and creators:

- **[Graphify](https://github.com/Graphify-Labs/graphify)** — Safi Shamsi (MIT) — the knowledge-graph engine.
- **[n8n](https://github.com/n8n-io/n8n)** — fair-code local automation.
- **[superpowers](https://github.com/obra/superpowers)** — Jesse Vincent — engineering skill marketplace.
- **[Anthropic Skills](https://github.com/anthropics/skills)** — official Claude skill library.
- **[marketingskills](https://github.com/coreyhaines31/marketingskills)** — Corey Haines — marketing skill marketplace.
- **[social-media-skills](https://github.com/charlie947/social-media-skills)** — social content skill marketplace.
