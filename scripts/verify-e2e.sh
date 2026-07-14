#!/usr/bin/env bash
# BrainV2 end-to-end verification — checks that every shipped feature actually works,
# not just that it was installed. Exit 0 = all PASS, exit 1 = at least one FAIL.
# Meant to be re-run in a loop (e.g. by /verify-brain2v under Fable 5) until clean.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

check() {
  local name="$1" ; shift
  if "$@" >/dev/null 2>&1; then
    printf '\033[32mPASS\033[0m  %s\n' "$name"; PASS=$((PASS+1))
  else
    printf '\033[31mFAIL\033[0m  %s\n' "$name"; FAIL=$((FAIL+1))
  fi
}

VAULT_PATH="$(python3 -c "import json;print(json.load(open('$REPO_DIR/app/config.json')).get('vaultPath',''))" 2>/dev/null)"
DASH_PORT="$(python3 -c "import json;print(json.load(open('$REPO_DIR/app/config.json')).get('port',7180))" 2>/dev/null)"

check "dashboard reachable (:$DASH_PORT)" curl -sf -m 3 "http://localhost:${DASH_PORT}/"
check "n8n healthz (:5678)" bash -c "curl -sf -m 3 http://localhost:5678/healthz | grep -q '\"status\":\"ok\"'"
check "graphify CLI installed" command -v graphify
check "graphify skill registered for claude" test -f "$HOME/.claude/skills/graphify/SKILL.md"
check "graphify graph built for vault" test -n "$VAULT_PATH" -a -f "$VAULT_PATH/graphify-out/graph.json"
check "claude plugin marketplace: superpowers" bash -c "claude plugin marketplace list 2>/dev/null | grep -qi superpowers"
check "claude plugin marketplace: claude-skills" bash -c "claude plugin marketplace list 2>/dev/null | grep -qi anthropic-agent-skills"
check "claude plugin marketplace: marketing-skills" bash -c "claude plugin marketplace list 2>/dev/null | grep -qi marketingskills"
check "claude plugin marketplace: social-media-skills" bash -c "claude plugin marketplace list 2>/dev/null | grep -qi social-media-skills"
check "n8n binary present" command -v n8n
check "app/config.json vaultPath set" test -n "$VAULT_PATH"

echo
echo "Result: $PASS passed, $FAIL failed."
[ "$FAIL" -eq 0 ]
