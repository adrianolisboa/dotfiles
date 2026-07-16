#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code via the official native installer (self-updating).
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
  echo "[claude-code] already installed — skipping"
  exit 0
fi

echo "[claude-code] installing via native installer..."
curl -fsSL https://claude.ai/install.sh | bash
