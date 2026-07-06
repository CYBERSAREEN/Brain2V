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

echo "Installing hook scripts -> $CLAUDE_DIR/hooks/"
mkdir -p "$CLAUDE_DIR/hooks"
for f in "$REPO_DIR"/hooks/scripts/*; do
  name="$(basename "$f")"
  if [ -e "$CLAUDE_DIR/hooks/$name" ]; then
    echo "  [skip] $name already exists"
  else
    cp "$f" "$CLAUDE_DIR/hooks/"
    chmod +x "$CLAUDE_DIR/hooks/$name"
    echo "  [ok]   $name"
  fi
done

SYNC_CONFIG="$CLAUDE_DIR/brain2v.sync.json"
if [ -e "$SYNC_CONFIG" ]; then
  echo "  [skip] brain2v.sync.json already exists (leaving your settings as-is)"
else
  cat > "$SYNC_CONFIG" <<'JSON'
{
  "enabled": false,
  "repo_path": "",
  "remote": ""
}
JSON
  echo "  [ok]   brain2v.sync.json (disabled template written to $SYNC_CONFIG)"
fi

echo
echo "Hooks CONFIG: NOT auto-merged (won't touch your settings.json)."
echo "Review hooks/settings.hooks.json — CHANGE:"
echo "  1. the vault path in the PostToolUse 'if:' conditions to your own vault"
echo "  2. the tokenguard-read-check.sh path if \$CLAUDE_CONFIG_DIR isn't ~/.claude"
echo "Then merge its \"hooks\" block into:"
echo "  $CLAUDE_DIR/settings.json"
echo
echo "GitHub auto-sync (organiser section 7) is OFF by default — $SYNC_CONFIG"
echo "has enabled:false. It will never push anywhere until YOU:"
echo "  1. run 'gh auth login' (or set up git) with YOUR OWN GitHub account"
echo "  2. edit $SYNC_CONFIG and set enabled:true, repo_path, and remote"
echo "    to your own fork/repo — never CYBERSAREEN/Brain2V"
echo
echo "Done. Open Claude Code and run /obs-organiser to start."
