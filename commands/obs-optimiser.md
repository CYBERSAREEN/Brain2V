---
description: The decision agent for EXTERNAL tooling. Recommends the best tool/framework for a job (pentest automation, learning, automation frameworks) from what's actually been recorded, logs the choice and its outcome, and improves its recommendations over time. Feeds off /obs-n8n, /obs-crewai, /obs-hermes notes. Distinct from /obs-organiser (which routes obs SKILLS, not external tools).
argument-hint: <"recommend <task category>" e.g. "recommend pentest automation" | "record <tool> <outcome>">
---

If `$ARGUMENTS` is empty, ask whether you want a **recommendation** or to **record an
outcome**, and stop.

> **Recommends only from evidence.** If the recorded notes don't contain enough to name a
> best tool, say so and recommend gathering data (via /obs-n8n, /obs-crewai, /obs-hermes,
> or a trial) — never invent a "best tool" the notes don't support. This is the guardrail
> that keeps this a decision agent, not a hallucination engine.

## Where it sits
`/obs-organiser` routes work to the right **obs skill**. `/obs-optimiser` decides which
**external tool/framework** to use for automation, learning, etc. Keep them distinct: if
the question is "which of my obs commands handles this?" that's the organiser; "which
automation tool should I use for this pentest workflow?" is the optimiser.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list,mcp__obsidian__tag_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## Categories & storage
Per-category decision logs under `<vault>/Optimiser/` (create if missing), e.g.:
- `pentest-automation.md`, `learning-tools.md`, `automation-frameworks.md` — extensible;
  make a new one when a genuinely new category appears.
Each holds: candidate tools known, the standing recommendation + why, and a dated
outcomes log.

## Mode A — Recommend
1. Identify the task category. `ls .obs-index/by-label/` and read the relevant
   `Optimiser/<category>.md` plus any `Automation/{n8n,crewai,hermes}/` notes (via the
   index, not a scan) that bear on it.
2. Recommend from that evidence: name the tool, give the concrete reason (a recorded
   outcome, a captured strength, a prior success), and state confidence honestly. If two
   are close, say so and give the deciding factor.
3. If evidence is thin: say "not enough recorded to recommend confidently" and propose
   what to capture or trial first. Do not manufacture a winner.
4. Log the recommendation (dated) in `Optimiser/<category>.md` so the next call sees it.

## Mode B — Record an outcome
After a tool was actually used, append a dated outcome to the category log: what it was
used for, how it went (worked / failed / partial), gotchas, and whether it changes the
standing recommendation. This is the feedback that makes future recommendations better —
without it the optimiser can't actually improve.

## File format & linking
Category notes: frontmatter `category`, `updated`, `tags: [optimiser, obs]`; `## Related`
linking `[[Optimiser/Optimiser-index]]`, `[[Journal/<today>]]`, and the relevant
`[[Automation/n8n/...]]` / `crewai` / `hermes` notes. Maintain `Optimiser/Optimiser-index.md`
mapping category → note + current standing pick.

## Index it
Upsert per the shared protocol — hash index + `by-label/optimiser/` symlink.

## Confirm
One line: the recommendation (with its confidence and the evidence it rests on) or the
outcome logged, and where.
