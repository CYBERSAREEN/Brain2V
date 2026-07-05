---
description: Reads back your recent journal/session/engagement data and briefs you on what's complete, what's incomplete, and what to start with next.
argument-hint: (none) — optionally a project/focus filter, e.g. "excelonCS" or "pentest"
---

No parameters required. If `$ARGUMENTS` is non-empty, treat it as a filter to narrow the
briefing to that project/focus/target only; otherwise cover everything found.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__vault_read,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Confirm `notesmd-cli` is on PATH. Determine the vault path via
`notesmd-cli list-vaults` (ask if ambiguous).

## 0b. Fast lookup and linking
Read `~/.claude/knowledge/obs-index-protocol.md` and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done —
the latter means most notes you read here will already carry a `## Related` /
`related:` pointer to other same-day notes, which is often a faster way to pull in
context than a fresh search.
Use the index (`<vault>/.obs-index/index.json`) to jump straight to the most recent
entries for `kind: journal`, `kind: context-log`, `kind: pentest`, and `kind: mistake` /
`kind: learning` instead of re-searching the whole vault — this command's entire job is
reading things other `/obs-*` commands already wrote, so the index should cover most of
it. Fall back to a full search only for anything the index misses.

## 1. Gather source material
Pull from every place other `/obs-*` commands leave state, most recent first:
- **`Journal/<date>.md`** (from `/obs-closeday`) — read the last 2-3 daily notes.
  `## Unfinished / carries to tomorrow` is the single strongest "what's incomplete"
  signal in the whole vault — treat it as such.
- **`Context/session-log.md`** (from `/obs-retain-context`) — the most recent snapshot's
  `**In flight**` and `**Open threads**` fields, if the file exists.
- **`Pentest/<target>/pen-context.md`** (from `/obs-pentest`) — for any engagement with
  entries, the latest phase's `**Next step**` field. An engagement with recent entries
  but no `report.md` yet in the same folder is incomplete by definition.
- **Active project notes** (same signal `/obs-context-code` uses — `status: active`
  frontmatter, `#project`/`#active` tags, or clear recency) — for each, check whether its
  own content marks anything done/shipped vs. still open.
- **`Mistakes/mistakes.md`** and **`Learnings/learnings.md`** — not task items
  themselves, but scan recent entries for a `do-not` that's directly relevant to
  whatever the top next-step turns out to be, so the briefing can carry the warning
  forward.
- If `$ARGUMENTS` was given, discard anything not matching that project/focus before
  building the briefing.

## 2. Reconcile complete vs. incomplete
An item counts as **complete** if a later note explicitly says so (a Journal "Progress"
entry, a `report.md` existing for a pentest engagement, a project note whose status
changed away from active) — don't infer completion from silence or old age alone.
An item counts as **incomplete** if it appears in an "Unfinished/carryover" or "Open
threads" list and nothing later marks it done.
An item with no recent activity at all (present in an old Journal/Context note, never
mentioned since, never marked done) is **stale** — flag it separately, don't silently
drop it and don't claim it's either done or actively in progress.

## 3. Prioritize the next step
Rank candidates for "what to start with" in this order, and pick the top one as the
headline recommendation (don't just list everything with equal weight):
1. An explicit carryover from the most recent Journal note (this is what the user
   themselves said was next, most recently).
2. An open thread from the most recent Context snapshot.
3. A pentest engagement with a logged `**Next step**` and no `report.md` yet.
4. Anything else incomplete, oldest first (longest-open items surface before newer ones).

## 4. Report
```
# Guide — <date>

## Start here
<the single top-priority next action, with a one-line reason it's ranked first, and a
pointer to the source note — plus that note's own [[Related]] links if it has any, so
the user can jump straight into the connected notes, not just this one>

## Complete (since <date of last briefing/journal entry>)
- <item> — [[source note]]

## Incomplete / carried over
- <item> — [[source note]] — <how long it's been open, if determinable>

## Stale (no activity, not marked done — flagged, not assumed)
- <item> — <last seen in, date> — [[source note]]

## Relevant warnings
- <any do-not from Mistakes/Learnings directly relevant to the top next step>
```
Use actual `[[wikilink]]` syntax for source notes (not just plain filenames) — this
output is meant to be pasteable straight into an Obsidian note if the user wants to keep
it, per the shared linking protocol.
If a section has nothing, say "none found" explicitly — don't omit it or leave the user
guessing whether you checked.

## 5. This is a live status read, not a new artifact
Same reasoning as `/obs-context-code`: this command's entire value is being *current*.
A saved copy of "what to do next" from days ago would actively mislead rather than help,
so don't persist this briefing to the vault — it's a re-derivable read of state that
already lives in other notes, not a new finding worth keeping on its own.

## 6. Apply it
Once delivered, treat the "Start here" recommendation as the working plan for the rest
of this session unless the user redirects — don't make them repeat back which item to
tackle first when you just told them.
