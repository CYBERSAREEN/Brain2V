---
description: Logs a mistake — build failure, wrong approach, or an AI hallucination/false-positive/false-negative — into the vault so it's never repeated. The Obsidian-side counterpart to ~/.claude/knowledge/learnings.md.
argument-hint: <what went wrong>
---

If `$ARGUMENTS` is empty, ask what mistake to log and stop — do not guess.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).

## 0b. Fast lookup
Read `~/.claude/knowledge/obs-index-protocol.md` once this session if not already done,
and check `<vault>/Mistakes/mistakes.md` for whether this exact mistake was logged
before — if so, this is a repeat, which is itself worth noting explicitly (the earlier
`do-not` clearly didn't stick, or wasn't read).

## 1. Classify
From `$ARGUMENTS` and recent conversation context, pick a `kind`: `build-failure` |
`ai-hallucination` | `false-positive` | `false-negative` | `process-mistake` | `other`.

## 2. Append
To `<vault>/Mistakes/mistakes.md` (create `Mistakes/` if missing) — format matches
`~/.claude/knowledge/learnings.md`'s entry format so both stores read the same way:
```markdown
### [YYYY-MM-DD] <short title>
- kind: <classification>
- what happened: <the mistake, plainly>
- root cause: <once understood>
- fix/correction: <what actually fixed it, or the correct fact>
- do-not: <the specific wrong approach to never retry>
- tags: <comma-separated>, obs
- related: [[Journal/<today>]]
```
Per `~/.claude/knowledge/obs-linking-protocol.md` (read once this session if not
already), always include the `related: [[Journal/<today>]]` line, plus any specific
engagement/project note this mistake came out of (e.g. `[[Pentest/<target>/pen-context]]`
for a pentest-derived mistake).

## 3. Cross-write when relevant
If this mistake is code/build/deploy/security related (not purely personal), also append
the same entry (reformatted to that file's exact `ENTRY FORMAT` block) to
`~/.claude/knowledge/learnings.md`, so the orchestrator pipeline's mandatory
before-work read picks it up too. Skip the cross-write for non-coding mistakes.

## 4. Update the index
Upsert `kind: mistake` keyed by the short title → `Mistakes/mistakes.md`.

## 5. Confirm
One line: saved (and note if it was cross-written to `learnings.md`, and whether this
was a repeat of an earlier entry).
