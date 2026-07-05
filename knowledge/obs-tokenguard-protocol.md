# Token-guard protocol — per-command cost awareness for root sessions

Claude Code on this machine runs as **root** (`/root/.claude/` is the active config for
every session here), so this protocol lives at the root level, not per-desktop-user —
unlike a GUI tool that would only apply to whichever desktop account launched it.

## Honest limit up front
There is no exact per-tool-call token meter available inside a skill or hook — Claude
Code doesn't expose "this Read cost exactly N tokens" to the model or to hook scripts.
Everything here is an **approximation** (roughly, output characters ÷ 4 ≈ tokens),
consistent enough to flag genuinely expensive calls and rank them, not precise enough to
report an exact bill. Say "approximately" when reporting costs — never state an estimate
as an exact figure.

## The two mechanisms

### 1. Real-time nudge (PreToolUse hook on `Read`)
Before a `Read` call executes, a hook script checks the target file's size on disk. Above
a threshold (default: 50KB / roughly 12–15K tokens), it emits an `additionalContext` nudge
naming the file and its size, and suggesting the cheaper alternative:
- Searching for something specific in it → prefer `Grep` (with `-C` for surrounding
  context) over a full `Read`.
- Only need a section → use `Read`'s `offset`/`limit` instead of the whole file.
- It's a large reference document being captured for the vault → run `/obs-distil` on it
  afterward so the *next* read of the essence is cheap, even though this first read still
  has to be full to extract anything.
- Genuinely need the whole file → proceed; the nudge is a reminder, not a block. This
  protocol never silently denies a `Read` — forcing "cheaper defaults" here means
  reliably reminding at the moment of the call, not preventing legitimate large reads.
This is a real, mechanical hook (not just a documentation convention) — see
`~/.claude/hooks/tokenguard-read-check.sh`, wired to `PreToolUse` on `Read`.

### 2. Session review (`/obs-tokenguard`)
On demand, or worth running near session end alongside `/obs-requests`: review this
session's tool calls (from context — same honest limit as `/obs-requests`, only what's
still in context is reviewable) and produce a report of the largest/most expensive calls,
what a cheaper approach would have looked like, and whether a pattern is worth adopting
as a standing default (feeds `/obs-code-personality`'s "how I like Claude to work" over
time, since that's exactly the kind of standing preference that skill is for).

## Calibration, not zealotry
The goal is not to minimize tokens at all costs — it's to spend them where they're
earning their keep (understanding, building, correctness) and not on avoidable bulk
(reading a whole file to find one string, re-reading something already distilled). A
correct answer that costs a few thousand extra tokens beats a wrong one that saved them.
