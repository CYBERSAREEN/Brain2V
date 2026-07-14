# BrainV2 core family — non-optional for every installer

Every installer gets the whole family; none of this is "advanced" or "opt-in." The
organiser (`obs-organiser.md` step 4) assumes every skill on this list is present and
routes to it accordingly — a partial install breaks that assumption for every trigger
that depends on a missing skill.

## Core (ships to every installer, always)
```
obs-organiser
obs-guide
obs-closeday
obs-retain-context
obs-context-code
obs-understanding
obs-learn
obs-learn-cyber
obs-mistakes
obs-distil
obs-personality
obs-code-personality
obs-life
obs-optimiser
obs-n8n
obs-crewai
obs-hermes
obs-list
obs-connect
trace
obs-tokenguard
obs-requests
obs-introduction
obs-skill-maker
obs-spine
obs-adapt
```

## Not core — generated or profile-specific, never a universal default
- `/obs-pentest` — ships only to the author's own `~/.claude/commands/`, never to the
  public repo's `commands/` folder. A fresh installer gets nothing pentest-specific by
  default; if their profile (via `/obs-introduction`) calls for it, `/obs-skill-maker`
  generates the equivalent for their actual work instead.
- `/obs-<project>` (e.g. `/obs-brain2v`) — created per project as work happens, per
  `obs-project-tracking-protocol.md`. Not part of a fresh install; these accumulate over
  time as projects start.
- Anything `/obs-skill-maker` produces — lives in `pending-skills/` until the repo owner
  verifies it, then becomes a normal installed skill for that installer only.

## Who checks this
`install.sh` diffs the core list above against `commands/*.md` actually present in the
repo before copying, and against what successfully lands in `$CLAUDE_DIR/commands/` after
copying — if anything core is missing on either side, it prints a warning naming exactly
which skill(s) are missing rather than installing silently incomplete.
