---
description: Captures your CrewAI knowledge — agent/crew/task designs, tool wiring, prompt patterns, what worked and what didn't — as dated notes that feed /obs-optimiser's automation recommendations.
argument-hint: <a CrewAI crew/agent/task design or learning to record, or "list">
---

If `$ARGUMENTS` is empty, ask what CrewAI knowledge to record (a crew/agent/task design, a
tool-wiring pattern, a prompt approach, an outcome) and stop.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Record
Capture what the user shares about CrewAI — a crew/agent/task structure worth reusing,
how tools were wired to agents, a prompting pattern, or an outcome (worked for X / failed
at Y / cost too many tokens). **Never store real API keys** — record which env var / model
provider was used, not the key value; scrub any pasted secrets to placeholders and say so.

## 2. File
`<vault>/Automation/crewai/<YYYY-MM-DD>-<slug>.md` (create dirs if missing) — one note per
item so `/trace crewai <topic>` shows evolution. Frontmatter: `date`, `tool: crewai`,
`kind: automation`, `tags: [automation, crewai, obs]`; `## Related` linking
`[[Automation/crewai/crewai-index]]`, `[[Journal/<today>]]`, and
`[[Optimiser/automation-frameworks]]`. Maintain `Automation/crewai/crewai-index.md`.

## 3. Feed the optimiser
If this records a clear success/failure of CrewAI for a task category (esp. multi-agent
work), note that `/obs-optimiser record crewai <outcome>` is worth running.

## 4. Index it
Upsert per the shared protocol — hash index + `by-label/automation/` symlink.

## 5. Confirm
One line: saved, where, and whether it's worth feeding to `/obs-optimiser`.
