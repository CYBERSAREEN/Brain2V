#!/usr/bin/env bash
# BrainV2 installer — copies the skill system into ~/.claude/ safely.
# It never overwrites your settings.json; it prints the hook block for you to merge.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

echo "BrainV2 installer"
echo "  source: $REPO_DIR"
echo "  target: $CLAUDE_DIR"
echo

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/knowledge"

echo "Installing commands -> $CLAUDE_DIR/commands/"
for f in "$REPO_DIR"/commands/*.md; do
  name="$(basename "$f")"
  if [ -e "$CLAUDE_DIR/commands/$name" ]; then
    echo "  [skip] $name already exists (run /obs-adapt inside Claude Code to safely merge updates instead of re-running this installer)"
  else
    cp "$f" "$CLAUDE_DIR/commands/"
    echo "  [ok]   $name"
  fi
done

# Core family completeness check — keep this list in sync with knowledge/obs-core-family.md
CORE_SKILLS=(
  obs-organiser obs-guide obs-closeday obs-retain-context obs-context-code
  obs-understanding obs-learn obs-learn-cyber obs-mistakes obs-distil obs-personality
  obs-code-personality obs-life obs-optimiser obs-n8n obs-crewai obs-hermes obs-list
  obs-connect trace obs-tokenguard obs-requests obs-introduction obs-skill-maker
  obs-spine obs-adapt
)
missing_from_repo=()
missing_from_install=()
for s in "${CORE_SKILLS[@]}"; do
  [ -e "$REPO_DIR/commands/$s.md" ] || missing_from_repo+=("$s")
  [ -e "$CLAUDE_DIR/commands/$s.md" ] || missing_from_install+=("$s")
done
if [ "${#missing_from_repo[@]}" -gt 0 ]; then
  echo "  [WARN] repo is missing core skill(s): ${missing_from_repo[*]}"
fi
if [ "${#missing_from_install[@]}" -gt 0 ]; then
  echo "  [WARN] install is missing core skill(s): ${missing_from_install[*]}"
fi

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

# Version marker + checksum manifest — the baseline /obs-adapt diffs future updates
# against. Only ever written/refreshed for files that exist in $CLAUDE_DIR right now;
# never overwrites content, just records what's there.
VERSION_FILE="$CLAUDE_DIR/.brainv2-version"
MANIFEST_FILE="$CLAUDE_DIR/.brainv2-manifest.json"
cp "$REPO_DIR/VERSION" "$VERSION_FILE"
echo "  [ok]   .brainv2-version ($(cat "$VERSION_FILE"))"

python3 - "$REPO_DIR" "$CLAUDE_DIR" "$MANIFEST_FILE" <<'PYEOF'
import hashlib, json, sys, pathlib
repo_dir, claude_dir, manifest_file = (pathlib.Path(p) for p in sys.argv[1:4])
manifest = {}
for sub in ("commands", "knowledge"):
    for f in sorted((repo_dir / sub).glob("*.md")):
        rel = f"{sub}/{f.name}"
        local = claude_dir / rel
        if local.exists():
            manifest[rel] = hashlib.sha256(local.read_bytes()).hexdigest()
for f in sorted((repo_dir / "hooks" / "scripts").glob("*")):
    rel = f"hooks/{f.name}"
    local = claude_dir / "hooks" / f.name
    if local.exists():
        manifest[rel] = hashlib.sha256(local.read_bytes()).hexdigest()
manifest_file.write_text(json.dumps(manifest, indent=2, sort_keys=True))
print(f"  [ok]   .brainv2-manifest.json ({len(manifest)} files recorded)")
PYEOF

SYNC_CONFIG="$CLAUDE_DIR/brainv2.sync.json"
if [ -e "$SYNC_CONFIG" ]; then
  echo "  [skip] brainv2.sync.json already exists (leaving your settings as-is)"
else
  cat > "$SYNC_CONFIG" <<'JSON'
{
  "enabled": false,
  "repo_path": "",
  "remote": ""
}
JSON
  echo "  [ok]   brainv2.sync.json (disabled template written to $SYNC_CONFIG)"
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
echo "    to your own fork/repo — never the original upstream repo you installed from"
echo
echo "Done. Open Claude Code — /obs-organiser calls /obs-spine first to work out which"
echo "flow applies to you (first-time setup vs. updating an existing install) and takes"
echo "it from there. If this really is your first time, expect /obs-introduction next."
