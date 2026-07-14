---
description: Detects which of BrainV2's three operating modes applies right now (author actively building it, a brand-new installer, or an existing installer updating) and tells the organiser which flow to follow. The framework /obs-organiser routes within.
argument-hint: (none) — runs the detection and reports the mode
---

No parameters. This is meant to run quietly and quickly at the start of an
`/obs-organiser` session, not as a big standalone investigation.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_list`. Determine the vault path via
`notesmd-cli list-vaults`. Read `~/.claude/knowledge/obs-spine-protocol.md` once this
session if not already done — this skill is that protocol's detection step.

## 1. Gather the signals (cheap — no vault scan)
- `~/.claude/brain2v.sync.json` — does it exist, and what is `enabled`?
- `~/.claude/.brain2v-version` — does it exist, and what does it contain?
- The BrainV2 repo's own `VERSION` file, if `repo_path` from the sync config (or a known
  local path) is reachable — compare its content to `.brain2v-version`.
- `ls <vault>/Personalities/*.md` (guard with existence check first, per the standing
  lesson about not blind-`ls`-ing a folder that might not exist) — does any note have
  `intake-complete: true` in frontmatter?

## 2. Decide the mode
Apply `obs-spine-protocol.md`'s three signal sets in order:
1. `enabled: true` in the sync config → **author**.
2. `enabled` false/absent, no `.brain2v-version` marker, no completed intake anywhere →
   **fresh-install**.
3. `enabled` false/absent, `.brain2v-version` exists, and it differs from the reachable
   repo's `VERSION` (or can't be compared because the repo isn't reachable locally, in
   which case say so rather than guessing) → **upgrade**.

If the signals don't cleanly match any of the three (e.g. a version marker exists but
matches the repo exactly — nothing to upgrade — or conflicting signals), report that
plainly and ask rather than forcing a mode.

## 3. Report and hand off
State the detected mode in one line, then act on it directly per the protocol:
- **author** → proceed exactly as `obs-organiser.md` §7 already describes; no further
  action needed from this skill.
- **fresh-install** → tell the organiser to offer `/obs-introduction` if it hasn't run
  yet this install.
- **upgrade** → tell the organiser to offer `/obs-adapt` (never auto-run a merge without
  saying so first — this is a bigger action than a routine trigger), and name what
  changed between the local version marker and the repo's current `VERSION` if that's
  knowable.

## 4. Honest limit
This is signal-based detection, not certainty. A hand-edited config or a missing marker
file can produce an ambiguous read — when that happens, say so and ask which mode
actually applies rather than silently picking one. Guessing wrong here risks exactly the
kind of overwrite `/obs-adapt` exists to prevent.
