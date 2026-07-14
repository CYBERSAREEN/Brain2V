#!/usr/bin/env bash
# BrainV2 v2 — service setup: Graphify, n8n, plugin marketplaces, dashboard config.
# Idempotent: safe to re-run. Designed to be driven by Claude Code (see CLAUDE.md),
# but works standalone. Nothing here touches your vault content.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
say()  { printf '\033[32m[brain2v]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[brain2v][warn]\033[0m %s\n' "$*"; }

# ---- 1. Graphify (knowledge-graph engine, graphify.net — MIT) -----------------
if command -v graphify >/dev/null 2>&1; then
  say "graphify already installed: $(graphify --version 2>/dev/null | head -1)"
else
  say "installing Graphify (PyPI package per graphify.net: 'graphifyy', CLI 'graphify')…"
  pip install graphifyy --break-system-packages -q \
    || pip install graphifyy -q \
    || warn "graphify install failed — install manually: pip install graphifyy"
  command -v graphify >/dev/null 2>&1 && graphify install \
    || warn "skipping 'graphify install' (CLI not on PATH yet)"
fi

# ---- 2. n8n (local automation) -------------------------------------------------
if command -v n8n >/dev/null 2>&1; then
  say "n8n already installed: $(n8n --version 2>/dev/null | head -1)"
else
  say "installing n8n globally (this can take a few minutes)…"
  npm install -g n8n --silent || warn "n8n install failed — install manually: npm install -g n8n"
fi

# ---- 3. Claude Code plugin marketplaces (from plugins.json) --------------------
if command -v claude >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  say "adding plugin marketplaces from plugins.json…"
  python3 - "$REPO_DIR/plugins.json" <<'PY' | while read -r src; do
import json, sys
for m in json.load(open(sys.argv[1]))["marketplaces"]:
    print(m["source"])
PY
    if claude plugin marketplace add "$src" >/dev/null 2>&1; then
      say "  + $src"
    else
      warn "  ✗ $src — slug not found; confirm the marketplace name and re-run"
    fi
  done
else
  warn "claude CLI not found — skipping plugin marketplaces"
fi

# ---- 4. Dashboard config --------------------------------------------------------
if [ ! -f "$REPO_DIR/app/config.json" ]; then
  cp "$REPO_DIR/app/config.example.json" "$REPO_DIR/app/config.json"
  warn "app/config.json created — set \"vaultPath\" to your Obsidian vault, then: node app/server.js"
else
  say "app/config.json present"
fi

say "service setup done. Start the brain:"
say "  node $REPO_DIR/app/server.js        # dashboard → http://localhost:7180"
say "  n8n start                            # automation → http://localhost:5678"
say "  graphify <your-vault-path>           # build the semantic graph (→ /graphify in dashboard)"
