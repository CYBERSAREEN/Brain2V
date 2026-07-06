# Obsidian per-project tracking protocol — one /obs-<project> per project, stage by stage

Brain2V documents itself (`/obs-brain2v`) using the same pattern every other project on this
machine should get: **every new project gets its own `/obs-<project-name>` skill**, whose
entire job is capturing that project's updates, errors, and design ideology as it happens —
from first commit through to production — so understanding never has to be reconstructed
from git log/memory later. This is distinct from `/obs-closeday` (the day's activity across
*everything*) and from a Personality's "Associated projects" line (a pointer, not a log) —
this is the durable, stage-by-stage story of one specific project.

## When a new `/obs-<project>` gets created
- `/obs-organiser` offers to create one the first time it notices sustained work on a
  project with no matching `/obs-<project>` skill yet (a new repo, a new `scope.md`, a
  string of edits under a project directory not seen before). Offer, don't force — some
  quick scripts never need this ceremony.
- The user can also ask directly ("track this project", "make an /obs-x for this").
- Naming: `/obs-<project-name>`, lowercased, hyphens for spaces (e.g. `/obs-brain2v`,
  `/obs-excelon-cs`). Keep it short — it's typed often.

## What every `/obs-<project>` skill must do
1. **Append-only stage log.** Each entry: what changed, why, what broke and how it was
   fixed (or a pointer to the `Mistakes/`/`learnings.md` entry — don't duplicate the full
   post-mortem, per the distillation protocol), and which stage this belongs to:
   `idea → build → testing → production`. A project note should always make it obvious
   which stage the project is currently in.
2. **Ideology, not just changelog.** Record the *why* behind non-obvious decisions (design
   direction, architecture calls, things deliberately left out of scope) — a plain
   changelog is derivable from git log; the reasoning is what's actually worth keeping.
3. **Mandatory backlink to the owning Personality.** Every `/obs-<project>` note ends with
   a link to whichever `Personalities/<name>.md` owns it (`## Related` per the linking
   protocol), and that persona's own "Associated projects" list gets the reverse link added
   — so opening the persona shows every project tied to them, and opening the project shows
   who owns it, in both directions, automatically via Obsidian backlinks.
4. **Tags:** `[project, obs]` plus a project-specific tag (e.g. `brain2v`).
5. **Stays a live note, updated in place** (like `Journal/<date>.md` is a hub for a day,
   a project note is a hub for that project) — not recreated each time, appended to.

## Index + linking
Same shared index (`obs-index-protocol.md`, `kind: project`, `label: project-<name>`) and
same linking protocol as every other `/obs-*` note — no special-casing.

## Relationship to /obs-skill-maker
`/obs-skill-maker` generates a *workflow* skill reflecting what a user does in general
(their profession/use-case, verified once at setup). A `/obs-<project>` skill is narrower
and ongoing: the running history of one specific project, however many personas or
skill-sets touch it. A single project can be owned by a persona whose workflow skill also
exists — both link to each other, neither replaces the other.

## Graph visibility — Skills/ stub notes
Skill definitions themselves (`~/.claude/commands/*.md`) live outside the vault entirely,
so Obsidian's graph has nothing to draw for them unless a vault-side pointer exists per
skill. Any project that documents a skill family (Brain2V's own `/obs-brain2v` being the
first case) should have a matching `<vault>/Skills/<name>.md` stub per skill actually
installed on that machine: a one-liner description + argument-hint pulled from the
command file's own frontmatter, its source path, a category tag, and a backlink to the
owning project note. The project note itself then links out to every stub it owns, so the
project becomes the graph's hub. `/obs-adapt` is what keeps these stubs in sync per
installer (add missing, update stale descriptions, never delete) — this is deliberately
never shipped as vault content in a repo; each installer's own stubs reflect their own
actual install.

## Honest limit
This is a documentation habit, not automation magic — nothing runs itself. The organiser
offering to create one, and the user (or a future capture hook) actually appending stage
entries as work happens, is what keeps a project note current. An `/obs-<project>` skill
nobody ever updates is exactly as stale as a journal nobody ever closes out.
