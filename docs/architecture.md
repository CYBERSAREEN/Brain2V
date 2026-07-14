# BrainV2 architecture

BrainV2 is not an app or a server — it's a **protocol layer over Claude Code + an
Obsidian vault.** There is no running process. Everything happens on the model's turns,
driven by three things: the skill definitions (`commands/`), the shared protocols
(`knowledge/`), and the hook nudges (`hooks/`).

## The three layers

```
┌─────────────────────────────────────────────────────────────┐
│  /obs-organiser  — orchestration / decision layer            │
│  routes each request, decides trigger-or-ask, closes loops   │
└───────────────┬─────────────────────────────────────────────┘
                │ invokes
┌───────────────▼─────────────────────────────────────────────┐
│  /obs-* skills — the workers                                  │
│  learn · mistakes · connect · list · guide · closeday · ...   │
└───────────────┬─────────────────────────────────────────────┘
                │ read/write via
┌───────────────▼─────────────────────────────────────────────┐
│  the vault + two indexes (source of truth = the notes)        │
│  hash index (O(1) exact) + symlink tree (filesystem-speed)    │
└─────────────────────────────────────────────────────────────┘
```

## Why two indexes

- **Layer 1 — hash index** (`.obs-index/index.json`): key = first 12 hex of
  `sha1(date|time|day|label)`. When you know the exact tuple, lookup is O(1) — no scan.
- **Layer 2 — symlink tree** (`.obs-index/by-date/`, `by-day/`, `by-label/`): one relative
  symlink per note. "Everything from Saturday" or "everything tagged pentest" becomes a
  plain `ls` of a directory — the OS's own directory index does the work, so it's as fast
  as the filesystem finds a file, at any vault size.

The indexes are **accelerators, not truth.** The notes are truth. If an index disagrees
with the vault, trust the vault and fix the index. Full protocol:
`knowledge/obs-index-protocol.md`.

## Why one graph

Every note a skill writes gets a `## Related` section of `[[wikilinks]]` plus a shared
`#obs` tag, so Obsidian's own graph/backlinks show one connected brain instead of ten
separate note piles. `Journal/<date>` is the daily hub everything links to. Full
protocol: `knowledge/obs-linking-protocol.md`.

## The loop

```
request
  → /obs-organiser: which skill? trigger automatically, or ask?
  → execute until the goal is met
  → learnings + mistakes captured (auto, via hooks)
  → human feedback
  → corrections written back: failures/errors → /obs-mistakes, lessons → /obs-learn
  → (next similar request reuses all of the above → cheaper, faster)
```

## What is honestly NOT automatic

- **No always-on watcher.** A hook/skill can't run continuously side-by-side; the model
  acts on turns. `/obs-organiser` is a protocol in force for the session, re-invoked at
  the trigger points in `docs/trigger-points.md` — not a daemon.
- **Hooks nudge, they don't execute.** A command-type hook injects an instruction into
  the model's context; the model then chooses to run the skill on its turn. So
  "auto-trigger" means "reliably prompted," not "fired by the OS."
- **"Faster each project" is reuse, not self-optimization.** The speed-up is real but it
  comes from resolving context via the index and reusing persisted work — it only
  materializes when that prior work actually exists to reuse.

Stating these plainly is a design principle here, not a disclaimer — the system is more
useful when its guarantees are honest.

## This repo stays in sync with the live skill system — per-installer, never hardcoded

Each installer's live `/obs-*` commands, protocols, and hooks under their own `~/.claude/`
are their working copy. Syncing that working copy back to a GitHub remote is entirely
config-driven via `~/.claude/brain2v.sync.json` (`enabled`/`repo_path`/`remote`) — nothing
in the shipped skill files ever hardcodes a specific person's repo or path, because this
repo is installed by people other than its original author. `install.sh` writes that
config disabled by default; an installer opts in with their own GitHub login and their own
repo. See `commands/obs-organiser.md` § "Keep BrainV2 in sync" for the exact rule,
including: routine edits to already-shipped skills sync automatically once opted in, but a
brand-new skill file always stops to ask first — a new feature being aired publicly is a
bigger decision than a routine sync.

## Onboarding a new installer (profile-driven, not one-size-fits-all)

BrainV2 doesn't assume every installer does the same kind of work. `/obs-introduction`
runs first on a fresh install, asks what the person does and what they want the setup
for, and stores that as a Work profile. `/obs-skill-maker` then drafts a skill reflecting
that actual work — saved to `pending-skills/`, never live until explicitly verified. Only
after verification does it become a real, routed skill for that installer. This is why
profession-specific skills (like pentesting) are never baked in as universal defaults —
see `knowledge/obs-core-family.md` for exactly what *is* core vs. generated per installer.

## Per-project tracking

Any project under active development can get its own `/obs-<project-name>` skill (e.g.
the author's own `/obs-brain2v`, tracking BrainV2's build — not shipped in this repo,
since it's specific to that one project/persona; see `obs-project-tracking-protocol.md`
to create your own) — a durable, stage-by-stage log of that
project's updates, errors, and design reasoning from build through production, always
backlinked to the persona that owns it. See `knowledge/obs-project-tracking-protocol.md`.

## The spine — one flow doesn't fit every machine

`/obs-organiser` routes *what* to invoke, but which flow is even correct depends on
context it can't assume: is this the author's own machine mid-build, a brand-new
installer, or an existing installer pulling an update over their own data? `/obs-spine`
detects this (`author` / `fresh-install` / `upgrade`, via `~/.claude/brain2v.sync.json`,
a version marker, and persona/intake state — see `knowledge/obs-spine-protocol.md`) and
runs first, every organiser session, before any routing happens. In `upgrade` mode it
hands off to `/obs-adapt`, which diffs the repo against a per-file checksum manifest
(`~/.claude/.brain2v-manifest.json`) to add what's missing, update what's unchanged since
the last sync, and never touch anything locally modified — the file-level version of the
same principle as never overwriting a user's data. `/obs-adapt` also keeps each
installer's own `Skills/` vault stubs in sync with whatever they actually have installed,
which is how every installer gets the graph-visibility fix without any personal vault
content ever shipping in the repo.
