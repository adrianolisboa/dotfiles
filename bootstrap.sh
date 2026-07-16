#!/usr/bin/env bash

# macforge fresh-Mac bootstrap.
# Installs Xcode Command Line Tools (for git), clones macforge, and runs setup.
#
# One-liner on a brand-new Mac (keeps the interactive prompts working):
#   bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
#
# Non-interactive:
#   bash <(curl -fsSL .../bootstrap.sh) --yes
#
# Overridable:
#   MACFORGE_REPO_URL   (default: https clone of adrianolisboa/macforge)
#   MACFORGE_DEST       (default: ~/Projects/macforge)

set -euo pipefail

REPO_URL="${MACFORGE_REPO_URL:-https://github.com/adrianolisboa/macforge.git}"
DEST="${MACFORGE_DEST:-$HOME/Projects/macforge}"

log() { printf '[bootstrap] %s\n' "$1"; }
die() { printf '[bootstrap] error: %s\n' "$1" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "This bootstrap targets macOS only."

# 1. Xcode Command Line Tools (provides git).
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (a dialog may appear)..."
  xcode-select --install || true
  log "Waiting for Command Line Tools to finish installing..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# 2. Clone (or update) macforge. HTTPS so it works before any SSH key exists.
if [[ -d "$DEST/.git" ]]; then
  log "macforge already present at $DEST — pulling latest."
  git -C "$DEST" pull --ff-only || log "Could not fast-forward; continuing with existing checkout."
else
  log "Cloning macforge into $DEST"
  mkdir -p "$(dirname "$DEST")"
  git clone "$REPO_URL" "$DEST"
fi

# 3. Run setup (passes through any flags, e.g. --yes).
cd "$DEST"
log "Running ./macforge setup"
exec ./macforge setup "$@"
