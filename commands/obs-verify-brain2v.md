---
description: Runs Brain2V's end-to-end verification script (dashboard, n8n, Graphify, plugin marketplaces) and, on any FAIL, fixes the root cause and reruns — loops until every check is genuinely green, not just installed.
argument-hint: (none) — runs against this machine's Brain2V install
---

Run `scripts/verify-e2e.sh` from the Brain2V repo root. It checks that every shipped
feature actually **works**, not just that it was installed: dashboard reachable, n8n
`/healthz`, the `graphify` CLI + its registered Claude skill, a built `graphify-out/graph.json`
for the configured vault, and the `verified:true` plugin marketplaces from `plugins.json`.

## Loop until clean
1. Run the script.
2. For each `FAIL` line, diagnose and fix the real cause (start a stopped service, fix a
   config path, install a missing binary) — never edit the script to make a check pass
   without the underlying feature actually working.
3. Re-run. Repeat until exit code is 0 (all PASS) or until a failure needs something only
   the user can provide (an API key, a real marketplace slug, a credential) — in which
   case stop and report exactly what's needed, don't loop forever on a blocker outside
   your control.
4. Log any real fix via `/obs-mistakes` / `/obs-learn` per the usual protocol, and update
   `Projects/Brain2V.md`'s stage log with the result.

This is the command to run under `/loop` (optionally on the Fable 5 model) for a
"keep testing and improving until every feature works end-to-end" session — each
iteration should either close a gap or clearly name the external blocker, never just
repeat the same failing check.
