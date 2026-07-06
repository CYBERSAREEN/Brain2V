---
description: First-run setup skill for a new Brain2V installer. Asks what the person does and what they want this setup for, then hands off to /obs-skill-maker to build a skill reflecting their actual work.
argument-hint: (none)
---

No parameters. This is the front door for anyone who found Brain2V from outside — a
GitHub browse, a recommendation, anywhere other than being walked through it directly —
so ask in plain language, don't assume prior context about the `/obs-*` family.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous — on a genuinely
fresh install there may be no vault registered yet; if so, ask where to create one before
anything else).

## 1. Guard — don't re-run over an existing setup by accident
`ls <vault>/Personalities/` first. If persona files already exist, say so and ask: is this
a new person's first setup on this same vault, or did you mean something else? Don't
silently overwrite or duplicate an existing persona's intake.

## 2. Ask, in the user's own words — not a rigid form
Cover these, but as a short conversation, not an interrogation:
- What do you do? (profession/domain — "I'm a chartered accountant", "I run a small dev
  shop", "I do pentesting", etc.)
- What do you actually want this setup to help you with day to day?
- Any tools, platforms, or workflows already central to that work (so `/obs-skill-maker`
  doesn't have to guess) — e.g. specific software, client types, recurring tasks.
- A name/label to use for their persona note (default to their first name if unsure).

Don't ask more than needed — if the answer to "what do you do" already implies the use
case clearly, don't force a separate question for it.

## 3. Write the intake
`<vault>/Personalities/<name-lowercase>.md` — create fresh if new, or append a
`## Work profile` section if a bare persona file already exists without one (e.g. one
`/obs-personality` created for credentials only, with no profession context yet).
```markdown
---
persona: <name>
intake-date: <date>
intake-complete: true
tags: [personality, obs, intake]
---
# <name>

## Work profile
- profession/domain: <answer>
- use-case for this setup: <answer>
- existing tools/workflow: <answer>

## Related
- [[Journal/<date>]]
```
If this note already has credential sections from `/obs-personality`, leave them
untouched — this only adds/updates the Work profile section.

## 4. Update the index
Upsert `kind: personality, label: <name>` → this note's path (same convention
`/obs-personality` uses), per the shared index protocol.

## 5. Hand off
Tell the user plainly what happens next: `/obs-skill-maker` will read this Work profile
and draft a custom skill reflecting how they actually work — offer to run it now rather
than making them type the command themselves.

## 6. Honest limit
This skill only gathers and stores the profile — it does not itself build any workflow
skill. That's `/obs-skill-maker`'s job, deliberately kept separate so the intake
(low-risk, just questions) and the generation (produces a draft that needs verification)
aren't the same step.
