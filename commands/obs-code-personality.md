---
description: Captures and applies your BUILD DNA — design style/colour palettes/web-dev structure, pentest ideology + preferred tools + HackerOne/Bugcrowd report style, and reusable code templates — so Claude builds and tests things your way without you re-explaining each time. The "how you build" counterpart to /obs-personality's "who you are".
argument-hint: <a preference to record, OR "apply design|webdev|pentest|reports" to load it before building>
---

If `$ARGUMENTS` is empty, ask whether you're **recording** a preference or want Claude to
**apply** an existing one, and stop — don't guess.

> This is a profile that GROWS from what you tell it. It never invents your preferences.
> Anything not yet captured is marked "not yet specified" so Claude asks instead of
> guessing your palette, stack, or methodology.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Domains
Build DNA is split into domain notes under `<vault>/CodePersonality/` (create if missing):
- `design.md` — colour palettes (exact hex), typography, visual style, layout/spacing
  preferences, things to always avoid.
- `webdev.md` — preferred stack, project structure, naming conventions, patterns you
  reach for, patterns you reject.
- `pentest.md` — your testing ideology/methodology, the tools you actually rely on (and
  in what order), how you decide what's worth chasing.
- `reports.md` — how you write HackerOne / Bugcrowd reports: structure, tone, severity
  framing, what you always include, your report templates.
- `code-templates.md` — reusable scaffolds/snippets you want reused verbatim.

## 2. Mode A — Record a preference
Route `$ARGUMENTS` (plus anything pasted) to the right domain note (ask if genuinely
ambiguous which). Append/update it with dated provenance:
```markdown
## <thing> — recorded <YYYY-MM-DD>
<the preference, in the user's own terms — exact hex, exact tool names, exact wording;
don't paraphrase away specifics>
```
If a preference contradicts something already recorded, don't silently overwrite —
note both and ask which is current (preferences evolve; that evolution is worth keeping
and is exactly what `/trace pentest ideology` etc. will later surface).

## 3. Mode B — Apply before building
When about to do web-dev or pentest work (or when asked to "apply <domain>"): read the
relevant domain note(s) first and actually build/test to them. For any field marked
"not yet specified", ASK rather than defaulting to a generic choice — a wrong guessed
palette or methodology is worse than a one-line question. After applying, if you learned
a new concrete preference during the work, offer to record it (Mode A).

## 4. File format & linking
Each domain note frontmatter: `domain: <name>`, `updated: <date>`,
`tags: [code-personality, <domain>, obs]`, and a `## Related` section linking
`[[CodePersonality/CodePersonality-index]]`, `[[Journal/<today>]]`, and any specific
project/persona it applies to. Maintain `CodePersonality/CodePersonality-index.md` as the
map (one line per domain note + last-updated date).

## 5. Index it
Upsert each domain note per the shared protocol — hash index + `by-label/code-personality/`
(or per-domain label) symlink — so Mode B loads it via lookup, not a scan.

## 6. Confirm
One line: which domain was recorded/applied, and where. If a domain is still mostly "not
yet specified", say so — it tells the user what Claude still needs from them to build
their way.
