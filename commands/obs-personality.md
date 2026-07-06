---
description: Stores a full identity/credential profile (git identity, tokens, API keys, associated projects) in the vault, keyed by persona name — the Obsidian-side counterpart to /personality.
argument-hint: <persona-name> [field=value ...]
---

> **Standing risk, confirmed twice by the user on 2026-07-04:** this command stores raw
> secret values in plaintext markdown in the vault, deliberately diverging from the rest
> of this machine's identity setup (`~/.claude/commands/personality.md` +
> `/home/kali/.secrets/personalities.env`, mode 600, references-only elsewhere). The user
> was shown that existing reference-only pattern explicitly and chose raw storage in
> Obsidian anyway ("keep it raw text, it will be safe with me... keep it in obsidian").
> That means every credential here is only as safe as the vault itself — if this vault is
> ever git-tracked, cloud-synced, or backed up somewhere shared, those secrets go with it
> in the clear. Mitigate by keeping `Personalities/` out of any sync/git tracking if that
> ever becomes a risk. This command does not re-litigate that choice again each run — it
> just stores what's given — but flag to the user if the vault ever starts
> syncing/tracking without that exclusion in place.

## Step 0 — Bootstrap import from /personality (one-time, run once per persona)
`/root/.claude/.personality.txt` already holds full `PROFILE: <NAME>` blocks (identity,
git, gh, ssh, vercel, supabase, render, env vars, per-project details, switch commands)
for personas already in use (currently VEDANT, ROUNAK, plus a shared RENDER block). When
asked to import/copy a profile from there, read the file, extract that persona's full
block verbatim, and write it — unmodified, full raw values — into
`<vault>/Personalities/<name-lowercase>.md`, preserving the source's own section
structure (Identity / Git / GitHub CLI / SSH / Vercel / Supabase / Render / env vars /
per-project blocks / switch commands) rather than forcing it into the smaller generic
template in Step 3 below — the generic template is for personas created fresh via
`/obs-personality`, not for ones migrated from the existing file. Note at the top of the
imported note: `imported-from: /root/.claude/.personality.txt` and the import date.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).

## 1. Resolve target file
`<vault>/Personalities/<persona-name>.md` (create `Personalities/` if missing). Parse
`$ARGUMENTS`: first token is `<persona-name>`; anything after is zero or more
`field=value` pairs.

If `$ARGUMENTS` has no persona name at all, list existing personas
(`ls <vault>/Personalities/`) and stop.

## 2. Read or write
- **Persona name only, no field=value pairs** → read that file and report its fields.
  Mask secret-looking values in the *chat reply* (`sk_live_****`, last 4 chars only) —
  the file itself keeps the full value; only the terminal echo is masked, and only
  show an unmasked value if the user explicitly asks for that specific field.
- **field=value pairs given** → upsert those fields into the note, creating the file if
  it's new. Never drop fields that already exist and weren't mentioned in this call.

## 3. File format
A persona note is not just a credential store — it's meant to reflect the person behind
it, growing over time, which is exactly what `/obs-life` tracks (career/priority shifts,
the "why" behind working-style changes). Keep them cross-linked so opening either one
surfaces the other, per `~/.claude/knowledge/obs-linking-protocol.md`.
```markdown
---
persona: <name>
updated: <date>
tags: [personality, obs]
---
# <persona-name>

## Identity
- git-name:
- git-email:

## Tokens / credentials
- github-token:
- vercel-token:
- supabase-token:
- render-token:
- other-api-keys:

## Associated projects
- <path>

## Related
- [[Personalities/<other-persona>]] — if this persona shares infrastructure (e.g. a
  Render account) with another, per `~/.claude/knowledge/obs-linking-protocol.md`
- [[Life/Life-index]] — this persona's career/priority trajectory over time, if `/obs-life` entries exist for them
- [[Journal/<date-created-or-last-edited>]]
```

## 4. Optional sync with /personality
If `/root/.claude/.personality.txt` also has a `PROFILE: <persona-name>` block for this
same name, tell the user both exist and ask which one is the source of truth before
overwriting either from the other — never assume a direction.

## 5. Update the index
Upsert `kind: personality` keyed by persona name → its file path, per the shared
protocol in `~/.claude/knowledge/obs-index-protocol.md`.

## 6. Confirm
State which fields were set (names only, not values) in one line.
