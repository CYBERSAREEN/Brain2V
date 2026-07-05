#!/usr/bin/env bash
# Brain2V installer — copies the skill system into ~/.claude/ safely.
# It never overwrites your settings.json; it prints the hook block for you to merge.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

echo "Brain2V installer"
echo "  source: $REPO_DIR"
echo "  target: $CLAUDE_DIR"
echo

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/knowledge"

echo "Installing commands -> $CLAUDE_DIR/commands/"
for f in "$REPO_DIR"/commands/*.md; do
  name="$(basename "$f")"
  if [ -e "$CLAUDE_DIR/commands/$name" ]; then
    echo "  [skip] $name already exists (remove it first to reinstall)"
  else
    cp "$f" "$CLAUDE_DIR/commands/"
    echo "  [ok]   $name"
  fi
done

echo "Installing knowledge -> $CLAUDE_DIR/knowledge/"
for f in "$REPO_DIR"/knowledge/*.md; do
  name="$(basename "$f")"
  if [ -e "$CLAUDE_DIR/knowledge/$name" ]; then
    echo "  [skip] $name already exists"
  else
    cp "$f" "$CLAUDE_DIR/knowledge/"
    echo "  [ok]   $name"
  fi
done

echo
echo "Hooks: NOT auto-merged (won't touch your settings.json)."
echo "Review hooks/settings.hooks.json — CHANGE the vault path in the PostToolUse 'if:'"
echo "conditions to your own vault — then merge its \"hooks\" block into:"
echo "  $CLAUDE_DIR/settings.json"
echo
echo "Done. Open Claude Code and run /obs-organiser to start."
