---
description: Life & career journal — captures updates about YOU (role changes, joining EY as Sr Security Engineer, priorities, constraints) and specifically WHY your working style shifts, so Claude understands the reason behind changes, not just the change. Distinct from /obs-closeday (work progress) — this is life context that reshapes how you work.
argument-hint: <a life/career update or journal entry, e.g. "joining EY as Sr Security Engineer next month">
---

If `$ARGUMENTS` is empty, ask what to journal and stop — don't invent life events.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Capture the entry
Record what the user said in their own words — a role change, a new job, a shift in
priorities, a constraint (time, focus, energy), a milestone. Do NOT editorialize or infer
big conclusions about their life; journal what they told you.

## 2. The "why it changes your work" hook (this is the point)
For anything that plausibly affects HOW the user works, add an explicit note on the
expected impact — but frame it as a hypothesis to confirm, not a fact you're asserting:
e.g. "joining EY as a Sr Security Engineer may shift pentest work toward
enterprise-scope/report-heavy engagements and stricter authorization boundaries — confirm
with the user how they want their working style to adapt." This is what lets Claude later
understand *why* the user's `/obs-code-personality` or project approach changed, instead
of treating a style change as unexplained. If it clearly connects to a build/pentest
preference, cross-link the relevant `[[CodePersonality/...]]` note.

## 3. File as its own dated note (traceable)
Path: `<vault>/Life/<YYYY-MM-DD>-<slug>.md` (create `Life/` if missing) — one note per
entry, deliberately, so `/trace <life theme>` can show how a situation evolved.
Frontmatter: `date`, `kind: life`, `tags: [life, obs]`, plus a `## Related` section
linking `[[Life/Life-index]]`, `[[Journal/<today>]]`, the relevant `[[Personalities/<name>]]`
note (this is the same person `/obs-personality` tracks — cross-link both ways, per
`~/.claude/knowledge/obs-linking-protocol.md`), and any affected
`[[CodePersonality/...]]` / project note. Body: the update, then an `## Impact on how I
work` section (or "no expected impact" if genuinely none).

## 4. Maintain the hub
`<vault>/Life/Life-index.md` — a running, dated list of life/career entries with a
one-line gist each, so `/obs-guide` and Claude at session start can see the current life
context at a glance without opening every note.

## 5. Index it
Upsert per the shared protocol — hash index + `by-label/life/` symlink.

## 6. Confirm
One line: saved, where, and whether an "impact on how I work" note was attached (and if
so, that it's a hypothesis awaiting the user's confirmation).
