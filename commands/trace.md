---
description: Trace how an idea/topic has evolved over time across the Obsidian vault — first appearance, evolution, and current connections.
argument-hint: <topic>
---
Topic given: `$ARGUMENTS`

If `$ARGUMENTS` is empty, ask the user what topic/idea to trace and stop — do not guess.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__vault_read,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Confirm `notesmd-cli` (aka `obsidian-cli`) is on PATH; if not, it's at
`/usr/local/bin/notesmd-cli`. Determine the active vault's real filesystem path via
`notesmd-cli list-vaults` (or ask the user which vault, if more than one is registered
and it's ambiguous which to search).

## 1. Search for all mentions of the topic
Search broadly, don't rely on one method — vault search and grep catch different things:
- `notesmd-cli search-content "<topic>"` for a content-text search via the CLI.
- `mcp__obsidian__search_query` (or `search_simple`) for the same, via the REST API/MCP path.
- A direct `grep -rniE "<topic>" "<vault path>" --include=*.md` for anything the above miss
  (partial words, code blocks, aliases) — the vault path came from `list-vaults` above.

Merge results into one deduplicated list of candidate note paths. Include notes that
mention the topic in body text, headings, tags (`#topic`), or frontmatter.

## 2. Follow backlinks to find related notes
There's no dedicated "backlinks" API — approximate it directly:
- For each candidate note found in step 1, take its title (filename without `.md`).
- `grep -rn "\[\[<note title>" "<vault path>" --include=*.md` to find every other note
  that links to it — those are its backlinks.
- Also check `mcp__obsidian__tag_list` for tags shared between candidate notes, and pull
  in any additional note that shares a tag with 2+ candidates — treat that as "related by
  theme" even if it doesn't literally say the topic string.
- Recurse one level: for newly-found related notes, grep for what links to *them* too, but
  stop after this second hop to avoid pulling in the whole vault.

## 3. Establish chronology
For every note in the merged set, determine when it entered the picture:
- Prefer a `created`/`date` field in frontmatter — read via
  `mcp__obsidian__vault_get_document_map` or `vault_read`.
- Otherwise fall back to filesystem timestamps (`stat -c '%Y %n' <file>` on the real vault
  path) — birth time if available, else mtime — and note that the date is approximate
  (filesystem-derived, not authored-on-that-date) when you report it.
- Sort all notes oldest → newest.

## 4. Output a timeline
Report back in this shape:

```
# Tracing: <topic>

## First appearance
<earliest note> — <date, marked "(approx.)" if filesystem-derived>
<1-2 line excerpt/quote of how it was first framed>

## Evolution
<chronological list, one entry per note that meaningfully develops the idea>
- <date> — <note title>: <what changed/was added to the idea vs. the prior mention>
(skip notes that just repeat the same mention with nothing new — say so briefly rather
than listing every trivial hit)

## Current connections
- Notes currently linking to it: <list>
- Shared tags: <list>
- Related-by-theme notes (no direct link, but overlapping tags/backlinks): <list>

## Organized synthesis
<only include this section if the source notes actually are cluttered, fragmented,
repetitive, or incomplete — skip it if the notes were already clean and there's nothing
to consolidate>
A clean, de-duplicated write-up of the idea as it stands today, built from everything
found in steps 1-3: merge repeated/overlapping points into one coherent statement, fill
in the shape of the idea from its parts (without inventing content that wasn't in any
note), call out gaps explicitly (e.g. "no note ever specifies X"), and drop stray
fragments that don't add anything. This is the reorganized version of the user's own
scattered thinking, not new content — every claim in it must trace back to something
actually read in step 1-3.

## Notes
<any ambiguity — e.g. multiple unrelated notes matched the search term, conflicting
dates, topic appears to have been renamed/merged with another concept — flag it here
rather than silently picking one interpretation>
```

Keep prose tight — this is a scan-able timeline, not an essay. Do not fabricate dates or
content for notes you didn't actually read. If frontmatter/filesystem dates are missing
entirely for a note, say "date unknown" rather than guessing.

## 5. Auto-save the timeline into the vault
After presenting the timeline in chat, always persist it into the vault too — this is
default behavior for `/trace`, no need to ask each time:
- Write it via `mcp__obsidian__vault_write` to `Traces/<topic, sanitized>.md` in the vault
  you searched (sanitize: trim, collapse whitespace, strip characters invalid in
  filenames).
- Include frontmatter: `topic`, `last-traced: <today's date>`, `tags: [trace]`, plus the
  same body you just showed in chat — timeline AND the "Organized synthesis" section if
  you produced one. The synthesis is the main payoff when source notes were messy, so it
  belongs in the saved note, not just the chat reply.
- If `Traces/<topic>.md` already exists (re-running `/trace` on the same topic later),
  overwrite it — the new run is the current, superseding version of that trace, not a
  duplicate to pile up.
- Tell the user in one line where you saved it (e.g. "Saved to Traces/<topic>.md").
- If the write fails (e.g. MCP unreachable), say so plainly — don't silently drop it or
  claim it saved when it didn't.
