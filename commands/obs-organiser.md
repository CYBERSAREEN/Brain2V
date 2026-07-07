---
description: The orchestrator ("brain") of the /obs-* system. Initializes the fast index at session start, routes each request to the right obs skill via hash lookup instead of full-vault scans, drives the request→execute→learn→feedback loop, and gets cheaper on repeat work by reusing persisted templates/learnings. Runs the whole obs family as one coherent system.
argument-hint: (none) — or a request/goal to route, e.g. "utha <persona> personality" or "pentest the <project> scope"
---

## What this is (and honestly, what it is not)
`/obs-organiser` is the routing-and-decision layer that makes the `/obs-*` family behave
like one brain instead of ten separate commands. It is a **protocol the model follows
across a session**, initialized once and re-consulted at defined trigger points — it is
**not** an always-on background process watching in real time. A slash command / hook
cannot run continuously side-by-side; the model only acts on turns. So "the organiser
watches everything till session end" means: the organiser protocol is in force for the
whole session, and gets re-invoked at the trigger points in step 4, not that a daemon is
polling. Say this plainly to the user if they expect a live watcher — don't imply one.

Likewise, "each repeat project costs fewer tokens / finishes faster" is **not** magic
self-optimization. The real mechanism is **reuse**: the organiser resolves context via
the hash index (O(1)) instead of scanning the vault, and pulls persisted templates,
prior solutions, design/pentest style, and past learnings/mistakes so the second similar
project *reuses* them instead of re-deriving from scratch. Build for that reuse; never
claim a guaranteed "4 months → 4 days" without the reuse actually being present.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list,mcp__obsidian__search_query,mcp__obsidian__tag_list`.
Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous). Read
`~/.claude/knowledge/obs-index-protocol.md` and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done —
the organiser's whole speed advantage comes from those two indexes.

## 1. Initialize (cheap — do NOT scan the vault)
On first invocation in a session:
- **Call `/obs-spine` first, before anything else below.** A "brain" routing requests
  without knowing whether this machine is the author's own (mid-build), a brand-new
  installer, or an existing installer updating is routing on a false assumption — see
  `~/.claude/knowledge/obs-spine-protocol.md`. The detected mode governs the rest of this
  session: `fresh-install` means offer `/obs-introduction` unprompted if it hasn't run
  yet; `upgrade` means offer `/obs-adapt` before assuming the local install reflects the
  current repo; `author` means proceed exactly as this file's own §7 already describes.
- Confirm `<vault>/.obs-index/index.json` and the `.obs-index/by-*/` symlink trees exist.
  If the index is missing or looks stale (notes newer than the index), rebuild it from
  the vault once (replay every `/obs-*` note through the write path in the index
  protocol) — this is the only time a full pass is acceptable, and it pays for itself by
  making every later lookup O(1).
- Do NOT read every note. Load only: the most recent `Journal/` entry, the most recent
  `Context/session-log.md` snapshot, and the `by-label/` directory listing (a filesystem
  `ls`, not a content scan) to know what kinds of notes exist. That is enough situational
  awareness to route intelligently at near-zero token cost.

## 2. Route the request to the right skill (hash lookup, not search)
Given the user's request (this turn's, or `$ARGUMENTS`):
- If it's a **fetch** ("utha `<persona>` personality", "get the `<project>` scope"): normalize to
  `label` + title, compute the hash key or `ls .obs-index/by-label/<label>/`, resolve the
  symlink, read that one note directly. Never grep the whole vault for something the index
  already points at.
- If it's an **action** that maps to an obs skill, consult the trigger table (step 4) and
  either invoke that skill or tell the user which one applies. Map examples:
  learning/knowledge → `/obs-learn` (or `/obs-learn-cyber` for cyber+AI content);
  an error+fix → `/obs-mistakes`; a pentest engagement → `/obs-pentest`; connecting two
  topics → `/obs-connect`; "what should I do next" → `/obs-guide`; "show me everything"
  → `/obs-list`; end-of-day → `/obs-closeday`; identity switch → `/obs-personality`.
- If a request maps to no obs skill, just do the work directly — not everything needs an
  obs skill, and forcing one wastes tokens.

## 3. Decide whether to trigger (Claude's call, or ask)
For each candidate skill, decide: **trigger automatically, or ask the user first?**
- Trigger automatically when it's clearly in-scope, low-risk, and additive (logging a
  learning, updating the index, running `/obs-guide` at session start).
- Ask first when it's ambiguous which skill applies, when it would write credentials
  (`/obs-personality`), when it would run active tooling against a target
  (`/obs-pentest` — always gated on a real `scope.md`), or when the user's intent isn't
  clearly "do it now." State the decision in one line so the user can override.

## 4. Trigger points (the table the organiser watches)
This mirrors `Brain2V/docs/trigger-points.md`; keep the two in sync.

| Skill | Organiser triggers it when… | Auto or ask |
|---|---|---|
| `/obs-guide` | session start / "what's next" | auto (already on SessionStart hook) |
| `/obs-retain-context` | context about to compact | auto (PreCompact hook) |
| `/obs-closeday` | session ending | auto (SessionEnd hook) |
| `/obs-learn` | user shares a reusable lesson / says "learn this" | auto on explicit ask; else offer |
| `/obs-learn-cyber` | cyber+AI content (PDF/course/MCP/"what I did") | auto on explicit ask; else offer |
| `/obs-mistakes` | a tool call fails and gets fixed | auto (PostToolUseFailure hook) once fixed |
| `/obs-connect` | a new note's Related links to a different-kind note | auto to *offer* (PostToolUse hook); ask before running |
| `/obs-list` | user wants an inventory, or index looks drifted | ask/offer |
| `/obs-personality` | identity/credential change | ask first — secrets |
| `/obs-pentest` | **only if present** — a pentest engagement with a real scope.md. Not shipped by default (see `/obs-skill-maker`); present on machines (like the author's) whose profile skill-set includes it | ask first — active tooling |
| `/obs-code-personality` | about to do web-dev/pentest work → load build DNA; or user states a design/methodology/report/template preference → record it | auto to load before building; auto-record on explicit preference, else offer |
| `/obs-introduction` | very first run on a fresh install with no persona/profile yet | auto-offer once on first session; never re-run over an existing profile without being asked |
| `/obs-skill-maker` | right after `/obs-introduction` completes a new profile | auto-offer; the generated skill is a **draft in `pending-skills/`**, never wired into routing until explicitly verified by the repo owner |
| `/obs-<project>` (e.g. `/obs-brain2v`) | sustained work on a project with no matching project skill yet | offer to create one, per `obs-project-tracking-protocol.md`; once it exists, trigger it same as any capture skill when that project's work happens |
| `/obs-spine` | every organiser session, first, before any routing | auto — this is what step 1 above always calls first |
| `/obs-adapt` | `/obs-spine` reports `upgrade` mode (repo has moved ahead of this install); or a fresh install's very first run, to write the baseline manifest | offer, never auto-run — merging files is a bigger action than a routine trigger, even though it never overwrites locally-modified content |
| `/obs-ai-redteam` | **local-only, personal** — generated by `/obs-skill-maker` for Vedant 2026-07-06, verified same day. Not part of the shipped repo, never push it there. Trigger on an AI red-teaming engagement (guardrail/prompt-injection/jailbreak testing) | auto on explicit "test/red-team this model" request; else offer |
| `/obs-life` | user shares a life/career update (role change, priorities, constraints) | auto on explicit share; else offer |
| `/obs-optimiser` | "which tool/framework for X?" (automation, learning, pentest tooling), or after a tool was used → record outcome | offer recommendation; auto-record outcome when the user reports one |
| `/obs-n8n` / `/obs-crewai` / `/obs-hermes` | user shares knowledge/config/outcome about that automation tool | auto on explicit share; else offer. These feed `/obs-optimiser`. |
| `/obs-distil` | user dumps a large PDF/brief/transcript and wants it "remembered", or a bloated raw-dump note is spotted | offer to distil (store only the required essence + a source pointer) — this is the storage-side token saving |
| `/obs-requests` | session ending (research this session's ambiguous prompts); or a new prompt matches a filed refined request | `SessionEnd` hook for the review; organiser checks `by-label/request/`, states the inferred requirement, and asks a fast permission check before applying it |
| `/obs-tokenguard` | on demand, or worth a look near session end | `PreToolUse` hook on `Read` nudges in real time (never blocks); the skill itself is offered, not auto-run |

Real-time efficiency: a `PreToolUse` hook on `Read` (`~/.claude/hooks/tokenguard-read-check.sh`)
nudges toward Grep/targeted-Read/`/obs-distil` on files over ~50KB. It's a reminder, not a
block — root sessions on this machine should default to the cheaper option, but a
genuinely necessary full read always proceeds.

The distillation protocol (`~/.claude/knowledge/obs-distillation-protocol.md`) is
system-wide: the organiser and every capture skill store the minimum required, never a
raw dump. Prefer distilled notes on read.

**Core family, non-optional.** Every row above except `/obs-pentest` and
`/obs-<project>`-style generated skills is core: `~/.claude/knowledge/obs-core-family.md`
lists exactly which skills every installer must have, and `install.sh` checks the install
against that list. Don't treat any core skill as something a "lite" install can skip —
the organiser assumes the whole family is present and routes accordingly.

New `/obs-*` skills added later MUST be given a row here and in
`Brain2V/docs/trigger-points.md` when created — that's how the organiser stays aware of
the whole family. They must also get a section in `docs/manual/MANUAL.html` (regenerate
`Brain2V-Manual.pdf` from it) — the manual is hand-authored, not auto-generated, and
already drifted stale once (2026-07-06) when this step was skipped.

## 5. Drive the loop, close it with learning
The employee-style loop the user described:
```
request → (organiser: which skill? trigger or ask?) → execute until the goal is met
        → learnings + mistakes captured (via the auto-trigger hooks) → human feedback
        → feed corrections back: failures/errors → /obs-mistakes, lessons → /obs-learn
```
The hooks already handle "capture on failure" and "offer connect on new note." The
organiser's job at the end of a unit of work is to make sure the loop actually closed:
was the mistake logged with its fix? was the reusable lesson saved? if the user gave
feedback, did it get written back? If any step was skipped, do it now — an
unclosed loop is how the system stops getting smarter.

## 6. Token-efficiency discipline (this is the point)
Every turn, prefer the cheapest path that's correct:
- index lookup / `ls .obs-index/by-*/` over `search`/`grep` over full read.
- reuse a persisted template or prior solution over re-deriving.
- load only the notes the task needs (via the index), never the whole vault.
Report, when relevant, that you used the index instead of a scan — it makes the
efficiency visible and keeps the discipline honest.

## 7. Keep Brain2V in sync (config-driven, per-installer opt-in)
This repo is public and installed by people other than its original author, so the sync
target is **never hardcoded here** — it's read from a local, git-ignored config the
installer owns: `~/.claude/brain2v.sync.json`:
```json
{ "enabled": false, "repo_path": "", "remote": "" }
```
- If the file is missing, or `enabled` is `false`, or `repo_path`/`remote` are empty:
  this standing duty is a no-op. Say so once if a sync-worthy edit happens, then stay
  quiet about it — don't nag every turn, and never attempt a push to a repo/remote that
  isn't explicitly configured.
- If populated and `enabled: true`: whenever any `/obs-*` command file, a shared protocol
  under `~/.claude/knowledge/`, or a hook script under `~/.claude/hooks/` is created or
  edited, sync the changed file(s) into `repo_path` (mirroring the same relative path:
  `commands/`, `knowledge/`, `hooks/scripts/`), regenerate `hooks/settings.hooks.json`
  from the live `~/.claude/settings.json`, then commit — using whatever `gh`/`git`
  identity is already active on this machine (never a hardcoded username — that identity
  is the installer's own, set up via `/personality` or plain `gh auth login`, and is
  expected to be overwritten freely after setup).
- **Before every push, verify the live identity first — and fix it yourself, silently.**
  Run `gh auth status` (or check `git config user.name`) and confirm the authenticated
  account actually matches the owner in `remote`. A vault/persona memory saying "X is
  active" is not proof; a past incident (2026-07-06) had a push fail 403 because the live
  session had silently drifted to a different persona than the one memory implied.
  **On mismatch, this is a mechanical correctness step, not a new consent point — don't
  stop to ask the user.** Switch to the correct persona using its known credentials
  (`Personalities/<name>.md` or `~/.claude/.personality.txt`), verify the switch actually
  landed (`gh api user --jq '.login'`), do the push, then restore whichever identity was
  active before you touched anything. State plainly afterward which identity was used and
  that it was restored — but the check-switch-verify-restore cycle itself is entirely
  your responsibility every time, not something the user should have to track or be asked
  about. (User feedback, 2026-07-06: "this is not my job to check who's logged into gh or
  not" — own it fully.) The one case that still needs an actual stop-and-ask is if no
  known credential exists for the required owner at all — then there's nothing to switch
  to, and guessing would be worse than asking.
- **New skill vs. routine edit — different rules:**
  - *Routine edit* (a bugfix, wording tweak, or protocol change to a skill **already**
    present in `repo_path`): auto-push once the identity check above passes. A config with
    `enabled: true` is standing, pre-authorized consent for exactly this case — don't ask
    permission for the push itself each time; do still say plainly, after the fact, what
    was pushed and the commit it landed in.
  - *New feature* (a brand-new `/obs-*` command file that doesn't yet exist in
    `repo_path/commands/`): **always ask before pushing**, regardless of `enabled`. A new
    skill is something being aired live for every other installer to see and adopt — that
    is a bigger decision than a routine sync and isn't covered by the standing
    pre-authorization. Commit locally if you like, but hold the push until the user
    explicitly says to go ahead.
- **Before every push (either case, and honestly before any `git commit` anywhere, not
  just Brain2V-sync pushes): secret-scan the diff first, silently, every time — this is
  now a standing duty, not a one-off check.** Read
  `~/.claude/knowledge/obs-security-protocol.md` once per session for the canonical
  pattern list (GitHub PAT, AWS key, private-key header, Supabase/Vercel/Render keys,
  OpenAI-style keys, generic `key=value` assignments — table is the source of truth,
  update it there first if a new provider needs coverage) and run
  `git diff --cached | python3 ~/.claude/hooks/security-secret-scan.py` (or the
  equivalent for a push: diff against the upstream tracking ref) before letting the
  commit/push proceed. A hit that isn't an obvious placeholder (`ghp_xxxx...`,
  `<your-key>`, `example`) means **stop and flag it before pushing, every time** — name
  which pattern matched, never echo the matched value itself into chat. This applies
  independently of whether the opt-in `PreToolUse` hook (`security-secret-scan.sh`,
  offered by `/obs-security-protocol`, not auto-wired) is installed on this machine —
  don't rely on the hook being present; the organiser owns this check itself.
  Also scan for any reference to external tools this project deliberately doesn't credit
  (check `[[obs_commands_built]]`-style memory for which names those are, without
  spelling them out in this file — this file is itself part of the repo).
- `install.sh` writes this config as a disabled template (`enabled: false`, empty
  `repo_path`/`remote`) on every fresh install — a new installer must deliberately opt in
  and point it at their *own* fork/repo before any auto-push can ever fire.

## 8. This is a live orchestration read, not a saved artifact
Like `/obs-guide` and `/obs-context-code`, `/obs-organiser` does not save its own note —
it's the live brain for *this* session. Its durable outputs are whatever the skills it
routes to save. Don't persist an "organiser log"; that's what `/obs-retain-context` and
`/obs-closeday` are for.
