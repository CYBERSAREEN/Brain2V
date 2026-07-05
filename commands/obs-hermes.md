---
description: Captures your Hermes knowledge — configs, workflows, and outcomes — as dated notes that feed /obs-optimiser. On first substantive use it confirms WHICH Hermes you mean so notes stay accurate (no assuming).
argument-hint: <a Hermes config/workflow/learning to record, or "list">
---

If `$ARGUMENTS` is empty, ask what Hermes knowledge to record and stop.

## 0. Disambiguate first (don't assume)
"Hermes" is ambiguous — it can mean the Nous Research Hermes LLM family, a messaging/
automation framework, or something specific to the user's stack. On the **first**
substantive note (or if `Automation/hermes/hermes-index.md` doesn't yet record which one),
ask the user which Hermes this is and note the answer at the top of the index, so every
later note is filed against the correct tool. Do not guess the referent — a wrong
assumption here poisons every downstream `/obs-optimiser` recommendation.

## 0b. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Record
Capture what the user shares about Hermes — a config, a workflow, a prompt/agent pattern,
or an outcome. **Never store real credentials/keys** — record the pattern and where the
secret lives; scrub any pasted secrets to placeholders and say so.

## 2. File
`<vault>/Automation/hermes/<YYYY-MM-DD>-<slug>.md` (create dirs if missing) — one note per
item so `/trace hermes <topic>` shows evolution. Frontmatter: `date`, `tool: hermes`,
`kind: automation`, `tags: [automation, hermes, obs]`; `## Related` linking
`[[Automation/hermes/hermes-index]]`, `[[Journal/<today>]]`, and
`[[Optimiser/automation-frameworks]]`. Maintain `Automation/hermes/hermes-index.md`
(with the disambiguation answer at the top).

## 3. Feed the optimiser
If this records a clear success/failure of Hermes for a task category, note that
`/obs-optimiser record hermes <outcome>` is worth running.

## 4. Index it
Upsert per the shared protocol — hash index + `by-label/automation/` symlink.

## 5. Confirm
One line: saved, where, and (on first use) which Hermes it was filed against.
