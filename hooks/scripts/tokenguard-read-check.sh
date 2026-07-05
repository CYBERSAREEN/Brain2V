#!/usr/bin/env bash
# PreToolUse hook for Read — nudges toward a cheaper alternative on large files.
# Never blocks the read (approximate cost only) — see obs-tokenguard-protocol.md.
set -euo pipefail

THRESHOLD_BYTES=51200  # ~50KB ≈ roughly 12-15K tokens, approximate

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

# No path, or file doesn't exist yet (e.g. about to error anyway) — say nothing.
if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

size=$(stat -c '%s' "$file_path" 2>/dev/null || echo 0)

if [ "$size" -le "$THRESHOLD_BYTES" ]; then
  exit 0
fi

size_kb=$(( size / 1024 ))
approx_tokens=$(( size / 4 ))

# Build the JSON with jq so paths/sizes are safely escaped.
jq -n \
  --arg path "$file_path" \
  --arg kb "${size_kb}KB" \
  --arg tok "~${approx_tokens}" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: ("About to read " + $path + " (" + $kb + ", approximately " + $tok + " tokens). If you only need a specific string, prefer Grep with context lines instead. If you only need a section, use Read with offset/limit. If this is a large reference document being captured for the vault, consider running /obs-distil on it afterward so future reads of the essence are cheap. If the full file is genuinely needed, proceed as normal - this is a reminder, not a block.")}}'
