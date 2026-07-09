# Plugin routing — which installed plugin the organiser reaches for

Brain2V installs several Claude Code plugin marketplaces at setup (see `plugins.json`),
but installing ≠ always-on. `/obs-organiser` decides per request which one is relevant,
the same way it routes to `/obs-*` skills. This doc is the routing map it reads.

## The map

| If the request is about… | Reach for | Notes |
|---|---|---|
| planning, debugging, TDD, refactoring, multi-step engineering | **superpowers** | the default for "build/fix this" software work |
| documents, spreadsheets, PDFs, slide decks, structured file output | **claude-skills** (Anthropic official) | prefer over hand-rolling file generation |
| marketing copy, positioning, SEO, landing-page words, launch messaging | **marketing-skills** | pairs with the web-build skills for a full site |
| content calendars, platform-native social posts, engagement hooks | **social-media-skills** | |
| (gstack — purpose to be confirmed with the owner on first real use) | **gstack** | slug unverified; confirm before relying on it |
| knowledge-graph / "how does this codebase/vault connect" questions | **Graphify** (`graphify`, `/graphify query`) | not a plugin — a service; build the graph first |
| local automation / "do X every time Y happens" / recurring jobs | **n8n** (`:5678`) | capture built workflows via `/obs-n8n` |

## Rules

1. **One request rarely needs more than one.** Pick the closest match; don't fan out
   across every plugin.
2. **Verify before first use.** For any `verified:false` entry in `plugins.json`, confirm
   the marketplace actually installed (it may have been skipped with a warning) before
   routing work to it.
3. **Log what worked.** When a plugin does a job well (or badly) for a task type, note it
   via `/obs-optimiser` so routing improves over time — same feedback loop as the
   external-tool decisions.
4. **The vault graph is Graphify's job, the code graph is too.** Route "show me how my
   notes/ideas connect" to Graphify's output (served at `/graphify` in the dashboard),
   not to a hand-built answer.
