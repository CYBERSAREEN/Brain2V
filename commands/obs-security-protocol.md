---
description: Audits a repo (local + GitHub remote) for leaked API keys/tokens, verifies .gitignore hygiene, and offers to wire the always-on secret-scan hook — so Claude never accidentally commits or pushes a user's credentials.
argument-hint: (none) — audits the current project's repo; or a path/repo name to audit a specific one
---

Read `~/.claude/knowledge/obs-security-protocol.md` in full first — it has the canonical
secret-pattern list and the standing rules this skill enforces. This skill covers
**credential leakage** (keys/tokens/passwords ending up somewhere they shouldn't), not
general OWASP code security — that's `/security-audit` / the `security-auditor` agent.

## 0. Identify the target
- If `$ARGUMENTS` names a path or repo, use that.
- Otherwise use the current working directory's git repo. If there isn't one, ask which
  repo to audit rather than guessing.
- Determine the active persona for this repo (check `Personalities/*.md` in the vault
  for an "Associated projects" entry matching this repo, or ask if ambiguous) — you need
  their currently-stored credential values to run the exact-value scan in step 2.

## 1. Read-only, always
Nothing in this skill deletes, force-pushes, or rewrites history. If a leak is found,
report it and propose a fix (rotate the credential, then `git filter-repo`/BFG to scrub
history) — do not act on the fix without the user explicitly asking for it separately.
This mirrors the global constitution's rule on hard-to-reverse operations.

## 2. Exact-value scan
Pull every credential value currently on file for the active persona
(`Personalities/<persona>.md` — GH token, Vercel/Supabase/Render tokens, DB passwords,
SSH key fragments, etc.). For each value, grep the **full** git history, not just HEAD:

```
git log --all -p -- . > /tmp/<scratch>/full-history.txt
```

then check each secret value against that dump (Python's `str.count` is simplest — avoid
piping the raw values through a shell command line where they might land in shell
history or process listings). Report count found per credential, never the value itself.

## 3. Generic pattern scan
Regex-scan the same history dump against the pattern table in
`obs-security-protocol.md` (GitHub PAT, AWS key, private-key header, Supabase, Vercel,
Render, OpenAI-style, generic key=value). For every hit, pull ~60 chars of surrounding
context to judge if it's a real value or a placeholder (`ghp_xxxx...`, `<your-key>`,
`sk-...redacted`) before flagging it as a genuine finding.

## 4. `.gitignore` coverage
Confirm credential-shaped filenames actually match a `.gitignore` rule:
`.env*`, `*.pem`, `*.key`, `id_ed25519`/`id_rsa`, `*personalit*`, `*.sync.json` or
similar per-project secret-config files, `*-auth-*.json`. If any are tracked in the repo
and NOT covered, that's a finding regardless of whether a scan found a live secret in
them yet.

## 5. GitHub-side check (if the remote is GitHub)
Check `gh auth status` for the currently active account. If it isn't the repo owner's
persona, switch **silently** per the global identity rule — no need to ask first, this
is a read-only check, not a push. Then:
```
gh repo view <owner>/<repo> --json visibility,isPrivate
gh api repos/<owner>/<repo>/collaborators
gh api repos/<owner>/<repo>/invitations
gh api repos/<owner>/<repo>/keys
gh api repos/<owner>/<repo>/secret-scanning/alerts
```
After the check, **switch back to whichever account was active before you started** —
don't leave the session authenticated as a different persona than the user had going in.

## 6. Offer the protective hook (once)
Check `~/.claude/settings.json` for an existing `PreToolUse` hook matching `Bash` that
calls `security-secret-scan.sh`. If missing, offer to wire it via the `update-config`
skill (don't wire it silently — this one changes behavior on every future commit, so it
gets a yes/no same as any other hook add). If present, skip — don't ask again this
session.

## 7. Report
```
# Security audit — <repo> — <date>

## Result: PASS | FAIL

## Exact-value scan
<per credential: clean, or "found in <N> commit(s), earliest <sha>">

## Pattern scan
<any genuine (non-placeholder) hits, with file/commit but never the matched value>

## .gitignore coverage
<covered / gaps, with the specific missing pattern>

## GitHub
<visibility, collaborator count + names, invitations, deploy keys, secret-scanning alert count>

## Recommended next steps (only if FAIL)
<rotate + scrub, specific commands, not auto-run>
```

## 8. Document it in the vault
Write the report to `Security/<repo>-security-audit-<date>.md` (create the `Security/`
folder if it doesn't exist yet — same pattern as `Pentest/<target>/`). Frontmatter:
`tags: [security, audit, obs]`, plus `repo:`, `date:`, `result:`. End with a `## Related`
section linking the persona note, the project note, and the same-day Journal entry (per
the linking protocol) — this is what makes the audit discoverable later via `/trace` on
the repo/persona name, and what lets `/obs-guide` surface it as recent activity without
any special-casing. Index it in `.obs-index` (`kind: security-audit`) the same way every
other `/obs-*` command does.

## 9. Keep the protocol current
The user said they'll keep refining this protocol over time. When they give a new rule
or pattern to add, append it to `obs-security-protocol.md`'s pattern table or standing
rules (and its Changelog section with a date) — don't overwrite prior rules, this is a
living document same as `learnings.md`.
