# Trigger points

Every `/obs-*` skill has a defined moment `/obs-organiser` considers invoking it. Some
fire via a Claude Code hook (reliably prompted by an event); others the organiser offers
based on the request. This table is the single source of truth — it must stay in sync
with the table inside `commands/obs-organiser.md`, and **every new skill added to
Brain2V must be given a row here.**

| Skill | Trigger | Mechanism | Auto or ask |
|---|---|---|---|
| `/obs-guide` | session start, or "what's next" | `SessionStart` hook | auto |
| `/obs-retain-context` | context about to compact | `PreCompact` hook | auto |
| `/obs-closeday` | session ending | `SessionEnd` hook | auto |
| `/obs-mistakes` | a tool call fails, once fixed | `PostToolUseFailure` hook | auto (after the fix) |
| `/obs-connect` | a new/edited vault note links to a different-kind note | `PostToolUse` hook (Write/Edit, vault-scoped) | auto to *offer*; ask before running |
| `/obs-learn` | user shares a reusable lesson / "learn this" | organiser decision | auto on explicit ask; else offer |
| `/obs-learn-cyber` | cyber+AI content (PDF / course / MCP / "what I did") | organiser decision | auto on explicit ask; else offer |
| `/obs-list` | user wants an inventory, or the index looks drifted | organiser decision | offer |
| `/obs-personality` | identity / credential change | organiser decision | **ask first — writes secrets** |
| `/obs-pentest` | a pentest engagement with a real `scope.md` — **only present if this installer's own `commands/` has it** (not shipped by default; see `knowledge/obs-core-family.md`) | organiser decision | **ask first — active tooling** |
| `/obs-introduction` | very first run on a fresh install, no persona/profile yet | organiser decision | auto-offer once; never re-run over an existing profile unasked |
| `/obs-skill-maker` | right after `/obs-introduction` completes a profile | organiser decision | auto-offer; output is a draft in `pending-skills/`, never routed to until verified |
| `/obs-<project>` (e.g. `/obs-brain2v`) | sustained work on a project with no matching project skill yet | organiser decision | offer to create, per `knowledge/obs-project-tracking-protocol.md` |
| `/obs-spine` | every organiser session, first, before any routing | organiser step 1 | auto — see `knowledge/obs-spine-protocol.md` |
| `/obs-adapt` | `/obs-spine` reports `upgrade` mode, or a fresh install's first run (baseline manifest) | organiser decision | offer, never auto-run |
| `/obs-code-personality` | about to build/test → load build DNA; or a stated design/methodology/report/template preference | organiser decision | auto-load before building; auto-record on explicit preference, else offer |
| `/obs-life` | user shares a life/career update | organiser decision | auto on explicit share; else offer |
| `/obs-optimiser` | "which tool for X?", or a tool outcome to record | organiser decision | offer recommendation; auto-record reported outcome |
| `/obs-n8n` / `/obs-crewai` / `/obs-hermes` | user shares tool knowledge/config/outcome | organiser decision | auto on explicit share; else offer (feeds `/obs-optimiser`) |
| `/obs-distil` | large PDF/brief/transcript to "remember", or a bloated raw-dump note | organiser decision | offer — stores only the required essence + source pointer (storage-side token saving) |
| `/obs-requests` | session ending (research ambiguous prompts from this session); or a new prompt matches a filed refined request | `SessionEnd` hook for the review; organiser states the inferred requirement and asks a fast permission check (never skipped) before applying a matched refinement |
| `/obs-tokenguard` | on demand, or worth a look near session end | organiser decision — offered, not auto-run. Paired with a real-time `PreToolUse` hook on `Read` (see below) |

## Real-time efficiency hook

A `PreToolUse` hook on `Read` (`hooks/tokenguard-read-check.sh` — a real script, not just
a static echo) checks the target file's size and, above ~50KB, nudges toward `Grep`,
targeted `Read` (`offset`/`limit`), or `/obs-distil`. It never blocks the read — a
genuinely necessary full read always proceeds; the hook only makes the cheaper option
visible at the moment it matters. See `knowledge/obs-tokenguard-protocol.md`.

## Hook mechanics (honest)

The hooks live in `hooks/settings.hooks.json`. They are **command-type hooks that print
an `additionalContext` instruction** — they do not themselves run a skill. The event
fires → the instruction lands in the model's context → the model runs the skill on its
turn. This is why every "auto" row above still depends on the model acting; the hook
guarantees the *prompt*, not the *execution*.

Two hooks are **vault-path-scoped** (`PostToolUse` on Write/Edit) via an `if:` condition
naming the vault directory. Anyone installing Brain2V must change that path to their own
vault, or the connect-offer nudge won't fire (and won't fire on the wrong files either).

## Adding a new skill later

When a new `/obs-<name>` is created:
1. Add its command file to `commands/`.
2. Give it a `## Related` section and the `#obs` tag per the linking protocol.
3. Register it in the fast index on first write per the index protocol.
4. **Add a row to this table and to the table in `commands/obs-organiser.md`** — this is
   how the organiser becomes aware of it. A skill the organiser doesn't know about is a
   skill that never gets triggered.
5. **Update `docs/manual/MANUAL.html` and regenerate `docs/manual/Brain2V-Manual.pdf`** —
   add the new skill's section (or update/remove an existing one on a material behavior
   change), fix the skill count in the titlepage and intro, then regenerate the PDF
   (`chromium --headless --disable-gpu --no-sandbox --print-to-pdf=docs/manual/Brain2V-Manual.pdf --print-to-pdf-no-header file://<absolute path to MANUAL.html>`,
   or `weasyprint` if chromium isn't available). The manual is hand-authored, not
   auto-generated — nothing keeps it current except this step. A stale manual (describing
   removed skills, missing new ones) is worse than no manual, so this is not optional.
   This drifted once already (2026-07-06: the manual still listed `/obs-pentest` as
   universal and was missing three new skills) — treat that as the standing example of
   what skipping this step costs.
6. **Create its `Skills/<name>.md` vault stub** (or run `/obs-adapt`'s graph-sync step,
   which does this for every skill actually installed, not just the new one) — per
   `knowledge/obs-project-tracking-protocol.md`'s graph-visibility pattern. Skipped once
   already too (2026-07-06: `/obs-spine` and `/obs-adapt` shipped and were fully wired
   everywhere else before anyone noticed neither had a stub, caught only when
   `/obs-adapt` was actually run and its own graph-sync logic flagged the gap in itself).
