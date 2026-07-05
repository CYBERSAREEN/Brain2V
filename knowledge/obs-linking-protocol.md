# Obsidian cross-linking protocol (shared by all /obs-* commands)

The fast-lookup index (`obs-index-protocol.md`) makes retrieval fast but is a hidden
JSON file — it doesn't make the vault itself feel connected when the user is actually
looking at notes in Obsidian. This protocol is what makes that happen: every note an
`/obs-*` command writes should visibly link to the other notes it's related to, so the
vault's own graph view and backlinks panel show one connected system, not isolated
silos per command.

## Rule 1 — every note gets a `## Related` section
Any note created/updated by an `/obs-*` command ends with:
```markdown
## Related
- [[Journal/2026-07-04]] — same-day journal entry
- [[Personalities/vedant]] — persona tied to this project
- [[Pentest/example.com/pen-context]] — related engagement
```
Populate it from:
- **Same-day notes** — check the index (`obs-index-protocol.md`) for any other `kind`
  with `date` == today; link to each.
- **Subject-related notes** — a persona's associated project, a pentest target's
  scope-derived project, a mistake that came out of a specific engagement, etc. Link
  even if the target note doesn't exist yet — Obsidian shows unresolved links as
  creatable, which is fine and expected; don't skip a link just because the note isn't
  written yet.
- Don't force it — if a note genuinely has nothing to relate to yet (e.g. the very
  first note of its kind in a fresh vault), leave `## Related` with `(none yet)` rather
  than omitting the section, so future runs know to check rather than assuming none
  was ever considered.

## Rule 2 — every note gets the shared `#obs` tag, plus its own kind tag
Frontmatter tags list should always include both, e.g. `tags: [personality, obs]`. The
kind tag (`journal`, `mistake`, `learning`, `personality`, `pentest`, `connect`,
`context-log`) groups same-kind notes; `#obs` is the umbrella tag so "show me
everything the obs system has ever touched" is one `tag_list`/search away — this is
what `/obs-connect`'s shared-tag detection and `/obs-guide`'s cross-source read rely on.

## Rule 3 — `Journal/<date>.md` is the day's hub
`/obs-closeday` is the one command that runs once a day and naturally touches
everything else logged that day. Its note should link out to every same-day note from
any other `/obs-*` command, and — since Obsidian backlinks are automatic — every one of
those notes linking back to `Journal/<date>.md` (per Rule 1) means the day itself
becomes a natural entry point into everything that happened on it, from either
direction.

## Rule 4 — `/obs-guide` surfaces the graph, doesn't just summarize it
When `/obs-guide` reads a note that has a populated `## Related` section, carry the
most relevant of those links into its own briefing output (not just a prose summary) so
the user can jump straight to a source note in Obsidian, not just read about it in the
terminal.

## Scope
Applies to: `/obs-closeday`, `/obs-learn`, `/obs-mistakes`, `/obs-personality`,
`/obs-pentest`, `/obs-connect`, `/obs-retain-context`, `/obs-guide`. `/trace`,
`/obs-context-code`, and `/obs-understanding` predate this protocol and were not
retrofitted — ask the user before extending it to them, same as the existing
`obs-naming-convention` memory already says not to rename `/trace` unilaterally.
