---
description: Generates a "digital twin" skill reflecting a user's actual profession/workflow, from the profile /obs-introduction gathered. Output is a draft in pending-skills/ — never wired into routing until explicitly verified.
argument-hint: <persona-name> (defaults to the most recently completed /obs-introduction intake)
---

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Determine the vault path via `notesmd-cli list-vaults`.

## 1. Read the source profile
Read `<vault>/Personalities/<persona-name>.md`'s `## Work profile` section (written by
`/obs-introduction`). If no persona name is given, use the most recent `intake-complete:
true` entry. If none exists yet, tell the user to run `/obs-introduction` first — this
skill has nothing to generate from without it.

## 2. Draft the skill — reflect their work, don't invent generic filler
Design a skill named `/obs-<short-slug-of-profession-or-use-case>` (e.g. a chartered
accountant's intake → `/obs-ca-workflow`) that is genuinely useful for *their* stated
work — not a reskinned template. Think about what they'd actually want tracked/automated:
recurring document types, client/engagement structure, what "done" looks like at each
stage of their work, what mistakes are worth remembering. Reuse the rest of the family
where it already fits instead of duplicating it — e.g. point at `/obs-mistakes` for
error capture, `/obs-distil` for large document intake, rather than reinventing those
inside the new skill.

Follow the same shape every other `/obs-*` skill uses: frontmatter
`description`/`argument-hint`, a `## 0. Tool setup` section, a clear single job, an
index-update step, a `## Related` output pointing back to `Personalities/<name>.md`.

## 3. Save as a draft — not live
Write to `<vault-or-repo>/pending-skills/obs-<slug>.md` (create `pending-skills/` if
missing) with frontmatter:
```yaml
status: pending-verification
generated-for: <persona-name>
generated-date: <date>
```
**Do not** copy it into `~/.claude/commands/` and **do not** add it to `obs-organiser`'s
trigger table yet — an unverified, auto-generated skill should not be live or routed to.

## 4. Local verification gate (required before this installer can use it)
Show the draft to whoever is running this session and ask them to confirm it actually
reflects their work before it becomes usable. On confirmation:
- Move `pending-skills/obs-<slug>.md` → `~/.claude/commands/obs-<slug>.md`.
- Add one row to the local copy of `obs-organiser.md`'s trigger table for it.
- Add a backlink both ways between `Personalities/<persona-name>.md` and the new skill.
On rejection or requested changes, revise the draft in place and ask again — don't
install a draft that wasn't approved.

## 5. Separate gate for shipping it to everyone (GitHub)
A locally-verified skill is personal to that installer — it is NOT automatically proposed
back to the public Brain2V repo. If the installer wants to contribute it upstream so other
people in similar work benefit, that is a **new skill file** by `obs-organiser`'s section 7
rule: it always stops to ask the repo owner before pushing, regardless of the sync config.
Don't conflate "verified for my own use" with "aired live for everyone" — they're two
separate, deliberate decisions.

## 6. Update the index
Upsert `kind: skill-draft` (pending) or `kind: skill` (once installed) → the file's path.

## 7. Honest limit
This produces a first draft, not a finished product — profession-specific nuance the
intake conversation didn't surface won't be in it. Treat the local verification step as a
real review, not a rubber stamp; revise rather than install something that's only
superficially relevant.
