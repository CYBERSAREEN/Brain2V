---
description: Loads your full life and work state into Claude Code — active projects, preferences, priorities, and current focus — by reading your Obsidian vault. Use at the start of any session where you want the agent to already know everything relevant about you.
argument-hint: (none) — optionally a focus area, e.g. "work" or "personal"
---

No parameters are required. If `$ARGUMENTS` is non-empty, treat it as a filter to narrow
the summary to that focus area only; otherwise cover everything.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__vault_read,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Confirm `notesmd-cli` is on PATH (`/usr/local/bin/notesmd-cli` if not).
Enumerate all registered vaults via `notesmd-cli list-vaults` — read across all of them,
this command's job is your whole life/work state, not one vault.

## 1. Gather source material
For each vault's real filesystem path:
- Recently modified notes: `find "<vault path>" -iname "*.md" -mtime -7` (last 7 days).
- Journal/daily notes from that same window, wherever they live in the vault.
- Notes carrying tags like `#project`, `#active`, `#priority`, `#focus`, or frontmatter
  fields like `status: active` — via `mcp__obsidian__tag_list` plus
  `notesmd-cli search-content` / `mcp__obsidian__search_query` for those markers.
- Anything reading like a standing preference or recurring theme (not time-boxed to 7
  days) — these round out "preferences" even if not touched recently.

## 2. Build the context load
Organize what you found into four buckets:
- **Active projects** — notes with a name + goal/status + ongoing tasks, active per an
  explicit status field, tag, or clear recency signal.
- **Recent reflections (last 7 days)** — journal/daily entries from that window,
  summarized close to the user's own words, not reinterpreted.
- **Priorities mentioned (last 7 days)** — anything phrased as a priority/goal/next-step
  in that window, quoted briefly.
- **Standing preferences** — durable working-style or life preferences, not time-boxed.

## 3. Report
```
# Context Load — <date>

## Active projects
- <project>: <one-line status>

## Recent reflections (last 7 days)
- <date> — <note>: <gist>

## Priorities (last 7 days)
- <date> — <priority, quoted briefly>

## Standing preferences
- <preference/theme>
```
If a bucket has nothing, say "none found" explicitly rather than omitting it — the user
should know the search came up empty, not wonder if you skipped it.

## 4. This is a live session load, not a new artifact
Unlike `/trace`, do not save this to the vault. It's a read of what already exists there
for *this session's* benefit — re-running it later just reflects the vault's state at
that time, so persisting a copy would just be clutter/duplication. If the user wants a
running history of context snapshots over time, that's a different, explicit ask.

## 5. Apply it
Once loaded, actually use this — treat active projects, priorities, and preferences
found here as already-known context for the rest of the session, the same way you would
information from Claude's own memory. Don't make the user repeat something you just read.
