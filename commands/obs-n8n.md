---
description: Captures your n8n knowledge — working workflows, node configs, credentials-handling patterns, gotchas, and what you automated — as dated notes that feed /obs-optimiser's automation recommendations.
argument-hint: <an n8n workflow/config/learning to record, or "list" to see what's captured>
---

If `$ARGUMENTS` is empty, ask what n8n knowledge to record (a workflow, a node config, a
gotcha, an outcome) and stop.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Record
Capture what the user shares about n8n — a reusable workflow, a node/credential pattern, a
gotcha that cost time, or an outcome ("this automation worked for X / failed at Y").
**Never store real credentials or webhook secrets in the note** — record the *pattern*
("uses an HTTP Request node with a bearer token from an n8n credential") and reference
where the secret lives, not the secret itself. If the user pastes a workflow JSON that
contains secrets, scrub them to placeholders before saving and say you did.

## 2. File
`<vault>/Automation/n8n/<YYYY-MM-DD>-<slug>.md` (create dirs if missing) — one note per
item so `/trace n8n <topic>` shows evolution. Frontmatter: `date`, `tool: n8n`,
`kind: automation`, `tags: [automation, n8n, obs]`; `## Related` linking
`[[Automation/n8n/n8n-index]]`, `[[Journal/<today>]]`, and `[[Optimiser/automation-frameworks]]`
so `/obs-optimiser` can weigh it. Maintain `Automation/n8n/n8n-index.md` as the map.

## 3. Feed the optimiser
If this note records a clear success/failure of n8n for a task category, note (one line)
that `/obs-optimiser record n8n <outcome>` is worth running so the recommendation basis
updates.

## 4. Index it
Upsert per the shared protocol — hash index + `by-label/automation/` symlink.

## 5. Confirm
One line: saved, where, and whether it's worth feeding to `/obs-optimiser`.
