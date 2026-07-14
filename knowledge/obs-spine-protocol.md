# Obsidian spine protocol — which flow the organiser is actually in

A "brain" without a spine has no framework holding its decisions together — `/obs-organiser`
routes *what* to invoke, but it was silently assuming one context the whole time: the
author's own machine, mid-build, safe to overwrite freely. That assumption is wrong the
moment anyone else installs BrainV2, and wrong again the moment even the author's own
machine goes from "building this for the first time" to "someone is updating an existing
install." `/obs-spine` is the missing layer: it detects which of three modes actually
applies *right now*, on *this* machine, and hands the organiser (and `/obs-adapt`) a
concrete flow to follow — instead of one flow pretending to fit every situation.

## The three modes

### 1. `author` — actively building BrainV2 itself
**Signal:** `~/.claude/brain2v.sync.json` exists with `enabled: true`. Only the original
author would opt into pushing their own edits straight back to their own repo — every
other installer's config ships disabled by default (per `install.sh`).
**Flow:** Full standing pre-authorization exactly as `obs-organiser.md` §7 already
describes — routine edits auto-sync, new skill files ask first, identity-check-and-switch
is Claude's own job. Nothing about ordinary use changes; this mode is what's been running
all session.

### 2. `fresh-install` — a brand-new installer, no prior BrainV2 state
**Signal:** `enabled: false` (or the sync config is absent) **and** no
`Personalities/*.md` note anywhere has `intake-complete: true` yet **and** no
`~/.claude/.brain2v-version` marker exists yet (nothing installed before this session).
**Flow:** Treat everything as new. Route through `/obs-introduction` before assuming any
profile-specific behavior (no pentest skill, no custom workflow — just the core family).
After intake, offer `/obs-skill-maker`. There is nothing to merge or preserve yet, so
`/obs-adapt` has no role here beyond writing the very first manifest/version marker.

### 3. `upgrade` — an existing installer pulling a newer BrainV2 version
**Signal:** `enabled: false` **and** `~/.claude/.brain2v-version` exists **and** its
content differs from the repo's own `VERSION` file (or a `commands/`/`knowledge/` file
the manifest tracks no longer matches what's on disk in the repo). This installer already
has their own data, their own generated skills, possibly their own edits.
**Flow:** Never re-run `install.sh`'s plain copy logic and never overwrite blindly.
Invoke `/obs-adapt`, which diffs the local install against the repo using
`~/.claude/.brain2v-manifest.json` (recorded at last install/adapt) to tell "shipped,
untouched since last sync" apart from "modified locally" — only the former is safe to
update automatically. See `commands/obs-adapt.md` for the exact merge rule.

## How the organiser uses this
`/obs-organiser` step 1 (initialize) calls `/obs-spine` first, before anything else, to
learn which mode applies this session. The mode then governs:
- Whether `/obs-introduction` is offered unprompted (fresh-install only).
- Whether `/obs-adapt` should be offered when the repo has moved ahead of what's locally
  installed (upgrade only — never silently auto-run without telling the user first, since
  merging files is a bigger action than a routine trigger).
- Whether §7's standing pre-authorization for pushing to GitHub applies at all (author
  only — a fresh-install or upgrade installer's own sync config starts disabled, so this
  is usually moot, but the mode check is what makes that explicit rather than assumed).

## Honest limit
Mode detection is signal-based, not certain — a user could hand-edit
`brain2v.sync.json` or delete `.brain2v-version` and produce an ambiguous read. When
signals conflict or nothing matches cleanly, `/obs-spine` says so plainly and asks rather
than guessing a mode, since guessing wrong here (e.g. treating an upgrade as a fresh
install) risks exactly the overwrite this whole protocol exists to prevent.
