# Brain2V architecture

Brain2V is not an app or a server — it's a **protocol layer over Claude Code + an
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
