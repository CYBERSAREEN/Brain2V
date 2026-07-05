---
description: Bridges two topics using your vault's link graph and shared tags to surface connections you haven't noticed yet.
argument-hint: <topic A> | <topic B>
---

Use when you're stuck, or suspect two ideas are related but can't see how.

Parse `$ARGUMENTS` into two topics (split on `|`, `" and "`, or `" vs "`). If fewer than
two topics are present, ask the user for the second topic and stop — do not guess one.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__vault_read,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Confirm `notesmd-cli` is on PATH (`/usr/local/bin/notesmd-cli` if not).
Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).

## 0b. Fast lookup
Before a full search, read `~/.claude/knowledge/obs-index-protocol.md` once this session
if you haven't already, and check `<vault>/.obs-index/index.json` for existing `kind:
trace` or `kind: connect` entries matching either topic — a hit saves you re-deriving a
note list you already built in a prior `/trace` or `/obs-connect` run. Always still
sanity-check a hit is current before relying on it.

## 1. Find notes for each topic
Independently, same technique as `/trace` step 1:
- `notesmd-cli search-content "<topic>"`
- `mcp__obsidian__search_query` / `search_simple`
- `grep -rniE "<topic>" "<vault path>" --include=*.md` for anything the above miss

Do this once for topic A, once for topic B. Dedup each into its own candidate list.

## 2. Build the link graph
For every note in each candidate list:
- List its outbound `[[wikilinks]]`.
- Find its backlinks: `grep -rn "\[\[<note title>" "<vault path>" --include=*.md`.

Then look for:
- **Direct link** — a topic-A note links straight to a topic-B note (or vice versa).
- **Bridge note** — a third note (in neither candidate list) links to both a topic-A
  note and a topic-B note.
- **Shared tags** — via `mcp__obsidian__tag_list`, tags that appear on notes from both
  lists.

## 3. Report
```
# Connecting: <Topic A> <-> <Topic B>

## Direct links
<A-note> -> <B-note>  (via [[link]])

## Bridge notes
<Bridge note> — links to both <A-note> and <B-note>

## Shared tags
#<tag> — appears on <A-notes> and <B-notes>

## Pattern observed
<1-3 sentences on what the connection actually suggests — skip this if nothing
meaningful turned up>
```
If steps 1-2 turn up no connection at all, say so plainly rather than forcing a pattern
that isn't there.

## 4. Save the result (default behavior, don't ask first)
This is a meaningful artifact (an analysis), not a one-off status message, so per this
user's standing preference, auto-save it — don't gate it behind asking first. Write it
to `<vault>/Connections/<topic A>--<topic B>.md` (sanitize each topic for filename
safety), with frontmatter `topic-a`, `topic-b`, `last-connected: <today>`,
`tags: [connect, obs]`. End the note with a `## Related` section wikilinking every
A-note and B-note actually used in the analysis (per
`~/.claude/knowledge/obs-linking-protocol.md`, read once this session if not already) —
this note IS the bridge itself, so it should link both ways rather than just describing
the connection in prose. Overwrite on rerun rather than piling up duplicates. Tell the
user in one line where it saved; say plainly if the save failed.

## 5. Update the index
Upsert the new `Connections/...` note (`kind: connect`) plus any newly-discovered A/B
notes, per the shared protocol.
