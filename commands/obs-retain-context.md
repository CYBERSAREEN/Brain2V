---
description: Manually snapshots the full current session (in-flight work, decisions, open threads) into the vault with a timestamp — a save-point for when a session is running low on context room.
argument-hint: (none)
---

**Important limit up front:** a slash command cannot fire itself automatically at some
context-usage threshold (e.g. "92%") — nothing invokes a skill without the user or a
hook doing so. True automatic triggering requires a hook (see the `update-config` skill
to wire up a `PreCompact`-style hook, or a context-usage warning hook). This command is
the manual save-point itself; run it yourself when you notice `/context` getting high, or
ask to have a hook fire it for you.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).

## 1. Build the snapshot
Summarize, in your own words, the current session as of right now:
- **In flight** — the task(s) actively being worked on.
- **Decisions** — choices made and why (especially anything non-obvious the user
  specified that isn't recoverable by re-reading code).
- **Files touched** — paths modified or created this session.
- **Open threads** — anything explicitly unresolved or waiting on the user.

Exact date/time via `date '+%Y-%m-%d %H:%M'`.

## 2. Save (append, never overwrite)
Append one entry per invocation to `<vault>/Context/session-log.md` (create `Context/`
if missing; frontmatter `tags: [context-log, obs]` on first creation):
```markdown
## <YYYY-MM-DD HH:MM> — Context snapshot
**In flight:** ...
**Decisions:** ...
**Files touched:** ...
**Open threads:** ...
**Related:** [[Journal/<today>]]
```
Per `~/.claude/knowledge/obs-linking-protocol.md` (read once this session if not
already), always include the `**Related:**` line pointing at today's Journal note.

## 3. Update the index
This is an append-only log, not one note per snapshot, so index it once —
`kind: context-log` → `Context/session-log.md` — rather than once per entry.

## 4. Confirm
Tell the user it saved. If they want true automatic firing at a context threshold,
point them at the `update-config` skill rather than pretending this command already
does that.
