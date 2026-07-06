---
description: Safely merges a newer Brain2V version into an existing install — adds what's missing, updates what's unchanged since the last sync, and never touches anything locally modified or personal. Also keeps each installer's own Skills/ vault graph in sync with whatever they actually have installed.
argument-hint: (none) — diffs the repo against this machine's install and reports before doing anything
---

This is the "won't overwrite, only adds/updates, never touches your data" merge — the
whole point of it existing is that a plain re-copy (what `install.sh` does on a fresh
install) is unsafe once real data exists: personas, custom-generated skills, hand edits.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Determine the vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-spine-protocol.md` once this session if not already done — this
skill is the mechanism `/obs-spine` hands off to in `upgrade` mode (and the one-time
baseline-builder in `fresh-install` mode).

## 1. Locate the manifest and version marker
- `~/.claude/.brain2v-manifest.json` — `{ "<relative path>": "<sha256 at last sync>" }`
  for every `commands/*.md`, `knowledge/*.md`, and `hooks/scripts/*` file. Written by
  `install.sh` on first install; updated by this skill after every run.
- `~/.claude/.brain2v-version` — the version string last synced.
- If **neither exists yet** (an installer who set up Brain2V before this skill existed):
  don't touch any file on this first run. Build the manifest from the **current** local
  file hashes (treat whatever's on disk right now as the pristine baseline going
  forward) and write `.brain2v-version` from the repo's `VERSION`. Report plainly that
  this was a baseline-only run — nothing was merged, so run `/obs-adapt` again to
  actually pick up any pending updates from this point on.

## 2. Classify every file the repo ships (`commands/`, `knowledge/`, `hooks/scripts/`)
For each file, compare three states: the repo's current content, the local file's
current content, and the manifest's recorded hash for that path.
- **Missing locally** → **add**: copy it in, record its hash in the manifest.
- **Present locally, local hash == manifest hash, repo content differs from manifest
  hash** → **update**: the file hasn't been touched since the last sync and the repo has
  moved on — safe to overwrite. Copy the repo's version in, update the manifest hash.
- **Present locally, local hash == manifest hash, repo content also unchanged** →
  nothing to do.
- **Present locally, local hash != manifest hash** → **locally modified — skip,
  always**, regardless of whether the repo also changed that file. Report it by name so
  the user knows an update exists but wasn't applied, and can merge by hand if they want
  it. This is the core promise: never touch a file the installer (or a generated skill,
  or a hand-edit) has changed.

## 3. Never touch — out of scope entirely, not even checked
Vault content (`Personalities/`, `Journal/`, `Mistakes/`, `Learnings/`, any note),
`pending-skills/` drafts, `~/.claude/brain2v.sync.json`, `~/.claude/.personality.txt`,
and anything not literally shipped under `commands/`, `knowledge/`, or `hooks/scripts/`
in the repo. This skill's blast radius is exactly the skill-system files, nothing else.

## 4. Keep this installer's Skills/ vault graph in sync (add/update, never delete)
Separately from the file merge above: scan whichever `/obs-*` command files actually
exist in this installer's own `~/.claude/commands/` right now (their real, current set —
including anything `/obs-skill-maker` generated for them, not a fixed list) and ensure
`<vault>/Skills/<name>.md` exists for each, per `obs-project-tracking-protocol.md`'s
graph-visibility pattern:
- Missing stub → **create** it (one-liner description + argument-hint pulled from that
  command file's own frontmatter, source path, category tag, backlink to whichever
  `Projects/<name>.md` this installer's own Brain2V-tracking note is, if one exists).
- Existing stub whose description no longer matches the command file's current
  frontmatter → **update** the stub's description only, leave everything else (any notes
  the installer added to that stub themselves) untouched.
- A skill removed from `~/.claude/commands/` → **do not delete** its stub. Leave it; a
  disappearing graph node is more confusing than a stale one, and the installer can
  delete it themselves if they want to.
This is what gives every installer the same graph-visibility fix without shipping any
personal vault content in the repo — each installer generates their own stubs for their
own actual install.

## 5. Report
One clear summary: files added (list), files updated (list), files skipped as locally
modified (list, with a one-line "an update exists" note each), Skills/ stubs created or
updated. Update `.brain2v-version` to the repo's current `VERSION` only after the file
merge completes successfully.

## 6. Honest limit
Hash comparison only detects *that* something changed, not *what* changed or whether a
skipped update was actually important — a skipped file might contain a genuinely
significant fix the user never sees applied. Naming the file plainly (step 5) is the
mitigation; this skill will never guess at a 3-way merge of file content.
