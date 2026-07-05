---
description: Captures something you just learned into the vault with the current date/time — general knowledge capture. For errors/mistakes specifically, use /obs-mistakes instead.
argument-hint: <what you learned>
---

If `$ARGUMENTS` is empty, ask the user what to record and stop — do not guess.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).

## 0b. Fast lookup / dedupe
Read `~/.claude/knowledge/obs-index-protocol.md` once this session if not already done.
Check `<vault>/Learnings/learnings.md` (create `Learnings/` if missing) for a
near-duplicate entry on the same topic from the last ~30 days — if found, append a dated
follow-up under that existing entry instead of creating a near-duplicate new one.

## 1. Append the entry
```markdown
### <YYYY-MM-DD HH:MM> — <short title derived from $ARGUMENTS>
<the learning, in full, in your own words but not distorting what was said>
tags: <inferred tags, comma-separated>, obs
related: [[Journal/<today>]]
```
to `<vault>/Learnings/learnings.md`. Per `~/.claude/knowledge/obs-linking-protocol.md`
(read once this session if not already), always add a `related: [[Journal/<today>]]`
line so today's Journal note (from `/obs-closeday`) backlinks here automatically, plus
any other clearly-relevant note (a project, a persona) if one applies.

## 2. Update the index
Upsert `kind: learning` keyed by the short title → `Learnings/learnings.md` (this is one
growing file, so the index maps topic → file, not topic → per-entry path).

## 3. Confirm
One line: saved, with the title used.
