---
description: "Remember this, minimally." Takes an over-explained brief, a whole PDF, or a long dump and stores ONLY the required essence in Obsidian (with a pointer to the source), so every future read costs far fewer tokens. BrainV2's native context-reduction feature.
argument-hint: <a path to a PDF/file, pasted text, or "distil <existing note>" to shrink a bloated note>
---

If `$ARGUMENTS` is empty, ask what to distil (a file path, pasted text, or an existing
bloated note) and stop.

> The point of this skill is to NOT store the raw material. It stores the distilled
> essence + a pointer to the source. Read
> `~/.claude/knowledge/obs-distillation-protocol.md` once this session — it is the rule
> this skill enforces.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-distillation-protocol.md`,
`~/.claude/knowledge/obs-index-protocol.md`, and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done.

## 1. Read the source (fully) — but don't store it
- **File path (PDF/text/md):** read it in full (the `Read` tool handles PDFs). Note the
  absolute path — that path is what goes in the note, not the file's contents.
- **Pasted text:** work from what was pasted.
- **Existing bloated note ("distil <note>"):** read it, then rewrite it smaller in place.

## 2. Distil to the required essence
Apply the protocol: extract decisions, specs, exact values, constraints, gotchas,
acceptance criteria — the load-bearing, reusable parts. Drop restatement, verbosity,
one-off context, redundancy. Scrub any secrets to placeholders. If the user over-explained
a project, keep the goal + hard constraints + decisions + acceptance criteria, not the
retelling. When unsure whether a detail is load-bearing, keep it (or rely on the source
pointer so nothing is truly lost).

## 3. Store the minimal note
Path: `<vault>/Distilled/<YYYY-MM-DD>-<slug>.md` (create `Distilled/` if missing).
Frontmatter: `date`, `kind: distilled`, `source: <absolute path or URL of the original>`,
`source-type: pdf|brief|transcript|note`, `tags: [distilled, obs]`.
Body:
```markdown
# <topic> — distilled <date>

## Source
<absolute path / URL>  — full material lives here; this note is the distilled index into it.

## Essence (what future work needs)
- <decision / spec / constraint / value / gotcha>

## Verbatim (only if a passage MUST be exact)
> <minimal quoted passage, if any>

## Related
- [[Distilled/Distilled-index]]
- [[Journal/<today>]]
- <any project / CyberAI / CodePersonality note this feeds>
```

## 3b. Cybersecurity content → also hand off to /obs-learn-cyber
If the material being distilled is cybersecurity- or AI-security-flavored, distilling it
is not the same job as learning from it: this skill's output is the *essence* (facts,
specs, values worth keeping) while `/obs-learn-cyber` is what actually captures *your
understanding* of the material and lets `/trace` show how that understanding evolved
over time. After saving the distilled note, auto-invoke `/obs-learn-cyber` on the same
source (don't ask first — this is additive, not destructive) so both exist: the
distilled essence, and the separate cyber-learning entry. Cross-link them both ways
(`## Related` in each pointing at the other) so `/obs-connect` can surface the pairing
later as a cross-connection worth noticing.

## 4. Report the saving honestly
Tell the user, in one line, roughly how much was cut (e.g. "distilled a 40-page PDF to a
~20-line note; original preserved at <path>") and confirm the source is still pointed to,
so nothing is actually lost — only the token cost of re-reading it later.

## 5. Hub + index
Maintain `Distilled/Distilled-index.md` (one line per distilled note → source + gist).
Upsert per the shared index protocol — hash index + `by-label/distilled/` symlink.

## 6. If the user insists on verbatim
If they explicitly want the whole thing stored verbatim, do it — but say plainly it costs
more tokens on every future read, and offer to keep the distilled version alongside as the
default read path.
