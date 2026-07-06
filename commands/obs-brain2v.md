---
description: Documents the Brain2V project itself — updates, errors, and design ideology, stage by stage from build through production. The first concrete instance of the /obs-<project> pattern (see obs-project-tracking-protocol.md). Owned by the vedant persona.
argument-hint: (none) — or a short note of what just happened, e.g. "shipped config-driven sync fix"
---

No required parameters. If `$ARGUMENTS` is given, treat it as this entry's headline —
what just happened — and gather supporting detail yourself rather than asking for more.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous). Read
`~/.claude/knowledge/obs-project-tracking-protocol.md` and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done —
this skill is the reference implementation of the first, and follows the second exactly.

## 1. What this note is (and isn't)
`Projects/Brain2V.md` is the durable, stage-by-stage story of the Brain2V project itself:
what changed, why, what broke, what stage it's in. It is **not** a changelog Claude
regenerates from `git log` — git already has that. This note is the *ideology*: the
reasoning behind decisions (e.g. "sync target became config-driven because the repo is
public and installers must never inherit CYBERSAREEN's push target"), the stage the
project is actually in, and pointers to the mistakes/learnings that shaped it.

## 2. Gather this entry's material
- This session's actual changes: files touched, commits made, `git log --oneline -5` in
  `/home/kali/Desktop/Brain2V`.
- Any `Mistakes/mistakes.md` or `~/.claude/knowledge/learnings.md` entries logged this
  session that relate to Brain2V — link them, don't re-paste them (distillation protocol).
- The current stage: `idea` (pre-code) → `build` (features being added, not yet installed
  by anyone but the author) → `testing` (installed/dogfooded, install.sh exercised
  end-to-end) → `production` (a real external installer has run it successfully). Brain2V
  is in **build** as of 2026-07-06 — update this line as it genuinely progresses, don't
  advance it optimistically.

## 3. Write / append the note
Path: `<vault>/Projects/Brain2V.md` (create `Projects/` if missing). If it already exists,
append a new dated entry under `## Stage log` rather than rewriting history.
```markdown
---
tags: [project, obs, brain2v]
project: Brain2V
owner-persona: vedant
current-stage: build
repo: https://github.com/CYBERSAREEN/Brain2V
---
# Brain2V

## Ideology
- Ships the skill *system* only — no vault content, no credentials, no third-party tool
  name-dropping in shipped docs.
- Any installer-identity-specific value (GitHub remote, repo path, persona credentials)
  must be config-driven and default to disabled/empty on fresh install — never hardcoded
  into a file that ships to every installer. (See the 2026-07-06 sync-target fix.)
- Profession-specific skills (pentest, CA workflows, whatever else) are generated per
  installer via `/obs-introduction` + `/obs-skill-maker`, not baked in as universal
  defaults — a chartered accountant installing Brain2V should never inherit a pentest
  skill by default.

## Stage log

### <date> — <headline>
- what: <what changed>
- why: <the reasoning, not just the diff>
- broke/fixed: <link to [[Mistakes/mistakes]] or learnings.md entry if one came out of this>
- stage: <idea|build|testing|production>

## Related
- [[Personalities/vedant]] — owning persona
- [[Context/session-log]]
```

## 4. Backlink the owning persona (mandatory, per the project-tracking protocol)
Add `Brain2V — /home/kali/Desktop/Brain2V — Projects/Brain2V.md` to
`Personalities/vedant.md`'s "Associated projects" list if not already present, so the
backlink is two-way: the persona shows the project, the project shows the persona.

## 5. Update the index
Upsert `kind: project, label: project-brain2v` → `Projects/Brain2V.md`, per the shared
index protocol.

## 6. Confirm
One line: entry saved, current stage, and whether the persona backlink was added or
already present.
