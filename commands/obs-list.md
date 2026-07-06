---
description: Detailed inventory of everything in the vault's /obs-* system — built from the fast filesystem index, not a full vault scan — and wired into /obs-connect, /obs-learn (+/obs-learn-cyber, /obs-mistakes), and /trace.
argument-hint: (none) — optionally a label/kind filter, e.g. "pentest" or "cyberlearn"
---

No parameters required. If `$ARGUMENTS` is non-empty, filter the inventory to that
label/kind only (e.g. `journal`, `mistake`, `personality`, `pentest`, `cyberlearn`,
`connect`, `context-log`).

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).
Read `~/.claude/knowledge/obs-index-protocol.md` and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done —
this command exists specifically to exercise the Layer 2 filesystem index from that
protocol, not to re-scan the vault.

## 1. Build the inventory from the index, not a vault scan
This is the whole point of this command: **use `.obs-index/by-label/*/` (and
`.obs-index/by-date/*/` if a date range matters) as the enumeration source.** For each
label directory, `ls` it to get every entry's symlink (which encodes time + key and
resolves to the real note path) — this is a filesystem listing, not a content search, so
it stays fast regardless of vault size. Only fall back to a full `notesmd-cli
search-content` / grep pass over the vault for anything genuinely not yet indexed (e.g.
notes created before the index existed, or by something other than an `/obs-*` command).

If `$ARGUMENTS` named a label, only enumerate `.obs-index/by-label/<label>/`. Otherwise
enumerate every label directory present under `.obs-index/by-label/`.

## 2. Organize by kind, with detail
For each entry found, resolve the symlink target and pull its frontmatter (date, tags,
title) — this is cheap since you're reading known paths, not searching. Group into
sections matching the established folders: **Journal**, **Learnings** (`/obs-learn`),
**Mistakes** (`/obs-mistakes`), **CyberAI** (`/obs-learn-cyber`), **Personalities**,
**Pentest**, **Connections** (`/obs-connect`), **Context log** (`/obs-retain-context`).
Within each section, sort oldest → newest and show: date, time, title as a `[[wikilink]]`,
and a one-line gist pulled from the note's own content (its first heading or summary
line — don't fabricate a gist from the filename alone).

## 3. Wire into /obs-connect
For every pair of entries that share a label/tag across *different* sections (e.g. a
`Personalities/<name>.md` note and a `Pentest/<project>/` engagement both tagged to the
same project), list them under a **Cross-connections worth running `/obs-connect` on**
subsection, with the exact suggested invocation, e.g. `/obs-connect <persona> | <project>
pentest`. Don't run the full `/obs-connect` analysis yourself here — this command's job
is to surface *which* pairs are worth connecting, not to duplicate that command's work.

## 4. Wire into /obs-learn family
Give the Learnings / Mistakes / CyberAI sections special treatment: for any label/topic
that has **2 or more entries**, add a note `(N entries — traceable)` next to it — this is
the same threshold `/obs-learn-cyber` step 7 uses, kept consistent across commands.

## 5. Wire into /trace
Collect every label/topic flagged `(N entries — traceable)` in step 4 into a closing
**Ready to /trace** list — one line per topic with the literal command to run, e.g.
`/trace MCP server security`. This is the single place in the whole `/obs-*` system that
tells the user which topics have enough history to make `/trace` worthwhile, instead of
them guessing.

## 6. Report
```
# Second Brain Index — <date>

## Journal
- <date> <time> — [[Journal/<date>]] — <gist>

## Learnings
- <date> <time> — [[Learnings/learnings]] — <gist> (N entries — traceable, if applicable)

## Mistakes
...

## CyberAI
...

## Personalities
...

## Pentest
...

## Connections
...

## Context log
...

## Cross-connections worth running /obs-connect on
- <entry A> <-> <entry B> — shared label/tag: <label> — try: `/obs-connect <A> | <B>`

## Ready to /trace
- <topic> (N entries) — try: `/trace <topic>`
```
If a section has nothing, say "none found" explicitly rather than omitting it.

## 7. Save (default behavior, don't ask first)
This is a meaningful artifact (a structural manifest), so per the standing auto-save
preference, save it — don't gate behind asking. Write to
`<vault>/Lists/Second-Brain-Index.md`, frontmatter `tags: [list, obs]`, `last-built:
<today>`. Overwrite on rerun (it's a snapshot of current state, not a log). Tell the user
in one line where it saved; say plainly if the save failed.

## 8. Update the index
Upsert this note itself (`kind: list`, `label: list`) per the shared protocol — both the
hash index and the by-label/by-date symlink tree — so a future `/obs-list` run, or
`/obs-guide`, can find it without a search.
