---
description: Reviews this session's tool calls for token cost, flags the expensive ones, and suggests a cheaper approach for next time. Root-scoped (Claude Code runs as root on this machine). Pairs with a real-time PreToolUse nudge on large Reads. Approximate cost only, always labeled as such.
argument-hint: (none) — reviews the current session
---

No parameters required. Read `~/.claude/knowledge/obs-tokenguard-protocol.md` once this
session if not already done — it defines the approximation heuristic and honest limits
this command follows; read it before reporting anything.

## 0. Honest limit up front
There is no exact per-call token meter exposed to a skill. Everything here is
approximate (roughly output-characters ÷ 4). Report costs as "approximately", never as
an exact figure. Only tool calls still in this session's context can be reviewed — same
limit as `/obs-requests`.

## 1. Review this session's tool calls
Look back over this conversation for large `Read`s, broad/unscoped `Grep`/`Glob`
sweeps, verbose `Bash` output, or repeated re-reads of the same file. For each
candidate, note: what was called, its approximate size/cost, and what a cheaper
approach would have looked like (targeted `Grep`, `Read` with `offset`/`limit`, a
result that should have been distilled via `/obs-distil` before this session instead of
re-read raw again).

## 2. Report
```
# Token Guard — <date>

## Expensive calls this session
- <tool call> — approximately <cost> — cheaper alternative: <what instead>

## Patterns worth adopting as a standing default
- <pattern, if one repeats across 2+ calls — worth feeding to /obs-code-personality as
  a "how I like Claude to work" preference>
```
If nothing stood out, say "nothing significant found — no expensive calls this
session" rather than manufacturing findings.

## 3. Offer to feed /obs-code-personality
If a genuine repeated pattern emerged (not a one-off), ask whether to record it as a
standing working-style preference via `/obs-code-personality` — don't record it
unasked, since that skill only grows from explicit input.

## 4. This is a live review, not a saved artifact
Same reasoning as `/obs-guide`: reviewing token cost only has value while current. Don't
persist this report to the vault as its own note — if a pattern is worth keeping, it goes
into `/obs-code-personality` instead (step 3), not here.
