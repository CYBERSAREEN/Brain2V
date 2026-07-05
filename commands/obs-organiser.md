---
description: The orchestrator ("brain") of the /obs-* system. Initializes the fast index at session start, routes each request to the right obs skill via hash lookup instead of full-vault scans, drives the request→execute→learn→feedback loop, and gets cheaper on repeat work by reusing persisted templates/learnings. Runs the whole obs family as one coherent system.
argument-hint: (none) — or a request/goal to route, e.g. "utha vedant personality" or "pentest the excelonCS scope"
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
- If it's a **fetch** ("utha vedant personality", "get the excelonCS scope"): normalize to
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
| `/obs-pentest` | a pentest engagement with a real scope.md | ask first — active tooling |
| `/obs-code-personality` | about to do web-dev/pentest work → load build DNA; or user states a design/methodology/report/template preference → record it | auto to load before building; auto-record on explicit preference, else offer |
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

New `/obs-*` skills added later MUST be given a row here and in
`Brain2V/docs/trigger-points.md` when created — that's how the organiser stays aware of
the whole family.

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

## 7. Keep Brain2V in sync (standing duty, pre-authorized — do not ask each time)
Whenever any `/obs-*` command file, a shared protocol under `~/.claude/knowledge/`, or a
hook script under `~/.claude/hooks/` is created or edited, sync the changed file(s) into
`/home/kali/Desktop/Brain2V` (mirroring the same relative path: `commands/`,
`knowledge/`, `hooks/scripts/`), regenerate `hooks/settings.hooks.json` from the live
`~/.claude/settings.json`, then commit and push to `github.com/CYBERSAREEN/Brain2V`.
Before every push: secret-scan the staged diff, and scan it for any reference to
external tools this project deliberately doesn't credit (check `[[obs_commands_built]]`-
style memory for which names those are, without spelling them out in this file — this
file is itself part of the repo). This was explicitly pre-authorized by the user
("jab bhi kuch bhi update karu brain2v me push karde") — don't ask permission for the
push itself each time; do still say plainly, after the fact, what was pushed and the
commit it landed in. If a secret or an undesired reference is ever found in the diff,
stop and flag it before pushing rather than pushing anyway.

## 8. This is a live orchestration read, not a saved artifact
Like `/obs-guide` and `/obs-context-code`, `/obs-organiser` does not save its own note —
it's the live brain for *this* session. Its durable outputs are whatever the skills it
routes to save. Don't persist an "organiser log"; that's what `/obs-retain-context` and
`/obs-closeday` are for.
