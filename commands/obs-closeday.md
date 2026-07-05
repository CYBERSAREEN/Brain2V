---
description: Reviews what you worked on today and logs a dated close-of-day note to the vault — progress, new ideas, unfinished carryover. Counterpart to /obs-context-code.
argument-hint: (none)
---

No parameters required.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list`
to load them. Confirm `notesmd-cli` is on PATH. Determine the vault path via
`notesmd-cli list-vaults` (ask if ambiguous).

## 0b. Fast lookup
Read `~/.claude/knowledge/obs-index-protocol.md` once this session if not already done.
Check the index for a `kind: journal, date: <today>` entry — if today's note already
exists (re-running this command later the same day), you're merging into it, not
creating a new one.

## 1. Gather today's material
- Notes modified today: `find "<vault path>" -iname "*.md" -newermt "$(date +%F)"`.
- This Claude Code session itself: summarize what actually got done in *this*
  conversation — files touched, decisions made, commands run. That's not in the vault;
  it only exists in this session's own history.
- Anything logged today by other `/obs-*` commands (`/obs-learn`, `/obs-mistakes`,
  `/obs-pentest`, etc.) — cross-reference via the index for today's date.

## 2. Write the close-day note
Path: `<vault>/Journal/<YYYY-MM-DD>.md` (create `Journal/` if it doesn't exist).
Frontmatter: `date`, `tags: [journal, closeday, obs]` (the `obs` tag per the shared
linking protocol below).
```markdown
# Close of Day — <date>

## Progress
- <what got done, close to your own words where the source was your own notes>

## New ideas that came up
- <idea>

## Unfinished / carries to tomorrow
- <item>

## Related
- [[<any other note any /obs-* command logged today>]]
```
If today's file already exists, merge new findings into the existing sections instead of
duplicating entries that are already there.

## 3. Link the day's hub (shared linking protocol)
Read `~/.claude/knowledge/obs-linking-protocol.md` once this session if not already
done. This note is the day's hub: `## Related` must list every other same-day note any
`/obs-*` command wrote (check the index for `date: <today>` across all `kind`s) —
`Mistakes/mistakes.md` entries, `Learnings/learnings.md` entries, any
`Pentest/*/pen-context.md` phase entries, any `Connections/` result. Since Obsidian
backlinks are automatic, those notes linking back here (per each command's own Related
step) means this Journal entry becomes a two-way entry point into the whole day.

## 4. Update the index
Upsert `kind: journal, date: <today>` → this note's path, per the shared protocol.

## 4. Confirm
Tell the user in one line where it saved.
