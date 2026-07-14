# obs-security-protocol — credential-leak prevention

Shared by `/obs-security-protocol` and the `security-secret-scan.sh` PreToolUse hook.
Purpose: make sure Claude never commits, pushes, or otherwise exposes a user's own API
keys/tokens/passwords to anyone else — accidentally or otherwise. This is about
**credential leakage**, not general OWASP code security (that's the separate
`security-auditor` agent / `/security-audit` command).

## Canonical secret-pattern list
Both the skill and the hook check for these shapes. Update this list first if a new
provider needs coverage — the hook script mirrors it in Python, so a pattern added here
should be added there too.

| Provider | Pattern |
|---|---|
| GitHub PAT | `gh[pousr]_[A-Za-z0-9]{20,}` |
| AWS Access Key | `AKIA[0-9A-Z]{16}` |
| Private key file | `-----BEGIN (RSA \|EC \|OPENSSH \|)PRIVATE KEY-----` |
| Supabase | `sb(p\|_secret\|_publishable)_[A-Za-z0-9_]{10,}` |
| Vercel | `vc[ar]_[A-Za-z0-9]{20,}` |
| Render | `rnd_[A-Za-z0-9]{20,}` |
| OpenAI-style | `sk-[A-Za-z0-9]{20,}` |
| Generic key=value | `(?i)(api[_-]?key\|secret\|password\|token)["']?\s*[:=]\s*["']?[A-Za-z0-9+/_\-]{16,}` (placeholders like `xxxx...`/`your-key-here` are exempt) |

Plus: any **exact value** currently stored in the active persona's `Personalities/*.md`
vault note (git tokens, DB passwords, service keys) — the skill pulls these live at
run time rather than hardcoding them here, since they rotate.

## Standing rules (apply on every session, not just when the skill is invoked)
1. **Never echo a real secret value into chat output**, a commit message, a vault note,
   or any file other than the credential store it already lives in
   (`Personalities/*.md`, `~/.claude/.personality.txt`, the tool's own config file).
   Reference secrets by name ("the GH token", "the Supabase service key"), never by value.
2. **Any shared/shipped repo must have `.gitignore` covering credential-shaped files
   BEFORE the first commit** — not retrofitted after. BrainV2's own `.gitignore` is the
   reference example (`.env`, `*.pem`, `*.key`, `id_ed25519`, `.personality.txt`,
   `brain2v.sync.json`, plus every vault-content folder).
3. **Before any `git commit` or `git push`**, the pattern list above gets checked
   against the staged diff. Two layers, don't rely on only one being present:
   - **Primary, always on:** the orchestrator (`/obs-organiser`) owns this as a standing
     duty — it runs the check itself on every commit/push it performs, independent of
     any hook being installed. See `/obs-organiser`'s sync-duty section.
   - **Secondary, opt-in:** `~/.claude/hooks/security-secret-scan.sh`, a `PreToolUse`
     hook on `Bash` matching `git commit`/`git push`, offered by `/obs-security-protocol`
     but never auto-wired — confirm with the user before adding it, since it changes
     behavior on every future commit machine-wide, not just orchestrated ones.
   Either way: never disable or bypass a real finding just to "get the commit through."
4. **Identity switches (gh/vercel/supabase/render) stay silent** — the account check,
   switch, and verification are Claude's own responsibility, never something the user
   should have to track or confirm before a push. But if the switch was only for a
   read-only check (not an actual push under that identity), restore the
   previously-active identity afterward so the session doesn't end up authenticated as
   the wrong persona for whatever comes next.
5. **A repo audit is read-only by default.** Finding a leaked secret does not mean
   force-pushing a history rewrite or deleting anything — report it, propose rotation +
   `git filter-repo`/BFG as the fix, and let the user decide when to act on it. History
   rewrites are exactly the kind of destructive operation that needs explicit
   confirmation first (see the global constitution's execution-care rules).

## What the skill checks, per run
1. Exact-value scan of full `git log --all -p` against every secret currently on file
   for the active persona (not just HEAD — a value removed in a later commit is still
   leaked if it was ever pushed).
2. Generic pattern-regex scan (the table above) across the same history, for secrets
   not tied to a known persona value (e.g. a stray key pasted from a different account).
3. `.gitignore` coverage check — do credential-shaped filenames actually match a rule.
4. If the remote is GitHub: repo visibility, collaborator list, outstanding
   invitations, deploy keys, and (if available) native secret-scanning alerts — as the
   *owner* identity, switching silently and restoring afterward per rule 4.
5. Report PASS/FAIL with specifics (which commit, which file, which pattern) but
   **never the matched value itself** in the report.

## Changelog
- 2026-07-08 — initial version, written after auditing the author's own BrainV2 fork
  (clean result: no secret values found anywhere in git history, single collaborator,
  no deploy keys, no native secret-scanning alerts).
- (updates land here as installers refine the protocol — append, don't overwrite)
