# Obsidian fast-lookup index protocol

Shared by all `/obs-*` commands so a request like "get me info about project X" can
resolve via a direct lookup instead of traversing the whole vault every time. Two layers:
a **hash index** (`index.json`, O(1) exact lookup when you already know date+time+day+
label) and a **filesystem-speed secondary index** (a directory tree of symlinks) for
"give me everything from Friday" / "everything tagged pentest" style browsing — the
latter is what actually delivers the "as fast as Linux searching a file or folder"
property, since it turns the query into a plain directory listing instead of a content
scan.

## Location
Both live under one dot-folder per vault, `<vault path>/.obs-index/` (same convention as
`.obsidian/`, so Obsidian's file explorer ignores it):
- `.obs-index/index.json` — the hash index
- `.obs-index/by-date/`, `.obs-index/by-day/`, `.obs-index/by-label/` — the symlink tree

## Layer 1 — Hash index (`index.json`)

### Shape
```json
{
  "a1b2c3d4e5f6": {
    "path": "Journal/2026-07-04.md",
    "title": "Close of Day — 2026-07-04",
    "kind": "journal",
    "label": "journal",
    "date": "2026-07-04",
    "time": "18:42",
    "day": "Saturday",
    "tags": ["journal", "closeday"]
  }
}
```
**Key = first 12 hex chars of `sha1("<date>|<time>|<day>|<label>")`** — `date` is
`YYYY-MM-DD`, `time` is `HH:MM` (creation time, minute precision), `day` is the full
weekday name derived from `date`, and `label` is the entry's primary tag/kind (`journal`,
`mistake`, `personality`, `pentest`, `cyberlearn`, etc. — same value as `kind` unless a
note needs a more specific label than its kind). Compute it with:
```bash
day=$(date -d "<date>" +%A)   # e.g. "Saturday" — derive, don't hand-type, to avoid drift
printf '%s' "<date>|<time>|<day>|<label>" | sha1sum | cut -c1-12
```
Minute-precision time makes collisions on the same date+day+label practically
impossible for how often these commands fire; if two entries ever do land in the same
minute, append `-2`, `-3`, ... to the key rather than overwriting.

### Read path (cache check before search)
1. Normalize the query the same way (date/time/day/label — time is often unknown, see
   below).
2. If you know the exact time, compute the key directly and `jq` it out of `index.json`.
   If you only know date+day+label (the common case — "what did I log on Tuesday about
   pentest"), use **Layer 2** instead (below) rather than trying every minute of the day.
3. Hit → read that note directly. Still worth a cheap staleness check (does the file at
   `path` still exist / still mention what's expected) since the vault can change outside
   these commands — if stale, fall through to step 4 and correct both layers.
4. Miss → do the normal full search (notesmd-cli / mcp search / grep), then upsert the
   result into both layers per the write path below so the next lookup is O(1).

## Layer 2 — Filesystem-speed secondary index (symlink tree)

For anything less precise than an exact date+time+day+label tuple — "everything from
today", "everything tagged `mcp-concept`", "everything from a Saturday" — don't compute
hashes at all. `ls`/`find` the relevant directory instead:

```
.obs-index/by-date/2026-07-04/          # every note created/updated that date
.obs-index/by-day/Saturday/             # every note ever created/updated on a Saturday
.obs-index/by-label/pentest/            # every note whose primary label is "pentest"
```

Each directory holds one **relative symlink per entry**, named `<time>--<slug>.md`,
pointing at the real note (e.g. `../../../Journal/2026-07-04.md`). Listing a directory
is a plain filesystem operation — this is the literal mechanism, not an analogy: the
OS already hashes/indexes directory entries for fast lookup, so reusing directories as
the index means the speed comes for free instead of being reimplemented in JSON.

```bash
# "what happened on Saturday, ever" — one filesystem listing, no vault scan
ls -la "<vault>/.obs-index/by-day/Saturday/"

# "everything about pentest work" — same
ls -la "<vault>/.obs-index/by-label/pentest/"
```

## Write path (upsert after any create/update)
After any `/obs-*` command creates or updates a note, update **both layers** in one pass:
```bash
python3 - <<'PY'
import json, pathlib, os, hashlib
from datetime import datetime

vault = pathlib.Path("<vault>")
idx_path = vault / ".obs-index" / "index.json"
idx_path.parent.mkdir(exist_ok=True)
idx = json.loads(idx_path.read_text()) if idx_path.exists() else {}

date, time_, kind, label = "<YYYY-MM-DD>", "<HH:MM>", "<kind>", "<label>"
day = datetime.strptime(date, "%Y-%m-%d").strftime("%A")
key = hashlib.sha1(f"{date}|{time_}|{day}|{label}".encode()).hexdigest()[:12]
rel_path = "<relative path, e.g. Journal/2026-07-04.md>"

idx[key] = {"path": rel_path, "title": "<title>", "kind": kind, "label": label,
            "date": date, "time": time_, "day": day, "tags": ["<tag>", "..."]}
idx_path.write_text(json.dumps(idx, indent=2, sort_keys=True))

# Layer 2 — symlink tree (relative symlinks so the vault stays portable)
for dim, value in (("by-date", date), ("by-day", day), ("by-label", label)):
    d = vault / ".obs-index" / dim / value
    d.mkdir(parents=True, exist_ok=True)
    link = d / f"{time_.replace(':','')}--{key}.md"
    target = os.path.relpath(vault / rel_path, start=d)
    if link.is_symlink() or link.exists():
        link.unlink()
    link.symlink_to(target)
PY
```
Keep `index.json` a plain flat object — no nesting beyond one level, so it stays
diffable and hand-editable if something ever needs manual correction. The symlink tree
is derived/regenerable from `index.json` at any time (rebuild by replaying every entry)
— never hand-edit symlinks, only regenerate them.

## What this is NOT
Both layers are accelerators, not sources of truth. The notes themselves are truth. If
either layer disagrees with the vault (moved/renamed/deleted file, broken symlink), trust
the vault, fix both layers, and move on — never report something as true solely because
an index or a symlink says so.
