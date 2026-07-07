#!/usr/bin/env bash
# PreToolUse hook for Bash — blocks `git commit`/`git push` if the staged diff (commit)
# or outgoing commits (push) contain a secret-shaped string. Mirrors the pattern list in
# ~/.claude/knowledge/obs-security-protocol.md — update both if a pattern is added.
set -uo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

if [ -z "$cmd" ]; then
  exit 0
fi

# Only act on git commit / git push invocations.
if ! printf '%s' "$cmd" | grep -qE '(^|[;&|]\s*)git\s+(commit|push)\b'; then
  exit 0
fi

diff_text=""
if printf '%s' "$cmd" | grep -qE '\bcommit\b'; then
  diff_text="$(git diff --cached -U0 2>/dev/null || true)"
else
  # push: check commits not yet on the remote tracking branch, if one exists
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -n "$upstream" ]; then
    diff_text="$(git diff "$upstream"..HEAD -U0 2>/dev/null || true)"
  else
    diff_text="$(git diff --cached -U0 2>/dev/null || true)"
  fi
fi

if [ -z "$diff_text" ]; then
  exit 0
fi

finding="$(printf '%s' "$diff_text" | python3 /root/.claude/hooks/security-secret-scan.py 2>/dev/null || true)"

if [ -n "$finding" ]; then
  jq -n --arg reason "$finding" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("Possible secret detected in the diff being committed/pushed: " + $reason + ". Confirm this is a placeholder/example before proceeding, or unstage the file and use an env var / credential store instead. See ~/.claude/knowledge/obs-security-protocol.md.")
    }
  }'
  exit 0
fi

exit 0
