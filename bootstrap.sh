#!/usr/bin/env bash

# macforge fresh-Mac bootstrap (chezmoi).
# Installs Xcode Command Line Tools (for git), installs chezmoi, then
# `chezmoi init --apply` clones the repo, lays down dotfiles (as symlinks),
# and runs the setup scripts (Homebrew, Brewfile, macOS defaults, iTerm2).
#
# One-liner on a brand-new Mac (keeps the interactive prompts working):
#   bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
#
# Overridable:
#   MACFORGE_GH  (default: adrianolisboa/macforge)

set -euo pipefail

GH_REPO="${MACFORGE_GH:-adrianolisboa/macforge}"

log() { printf '[bootstrap] %s\n' "$1"; }
die() { printf '[bootstrap] error: %s\n' "$1" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "This bootstrap targets macOS only."

# 1. Xcode Command Line Tools (provides git, needed by chezmoi to clone).
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (a dialog may appear)..."
  xcode-select --install || true
  log "Waiting for Command Line Tools to finish installing..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# 2. Ensure chezmoi is installed AND on PATH for this run. get.chezmoi.io drops
#    the binary in ./bin (not on PATH), which is why `chezmoi update` came back
#    "command not found". Install it to ~/.local/bin and prepend that. (chezmoi is
#    also in the Brewfile, so brew bundle later puts it on the permanent PATH.)
if ! command -v chezmoi >/dev/null 2>&1; then
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v chezmoi >/dev/null 2>&1; then
    log "Installing chezmoi to ~/.local/bin"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  fi
fi

# 3. Apply the repo. `chezmoi init` clones only when the source is absent — it
#    never pulls an existing clone, so a re-run would otherwise re-apply a stale
#    copy (the reason a manual `rm -rf` was ever needed). If a clone already
#    exists, fast-forward it to the remote and apply — so re-running this
#    bootstrap self-heals, no rm -rf. If it has diverged or has local changes we
#    refuse rather than discard work.
#    chezmoi asks "Is this a work machine?" on first init, then applies everything.
SRC="$(chezmoi source-path 2>/dev/null || true)"
ROOT=""
[ -n "$SRC" ] && ROOT="$(git -C "$SRC" rev-parse --show-toplevel 2>/dev/null || true)"

if [ -z "$ROOT" ]; then
  log "fresh install — init --apply $GH_REPO"
  exec chezmoi init --apply "$GH_REPO"
fi

if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  die "clone at $ROOT has local changes — commit or stash them, then run 'chezmoi update' (no rm -rf needed)."
fi

log "existing clone at $ROOT — fast-forwarding to latest remote, then applying"
git -C "$ROOT" fetch --prune origin
UPSTREAM="$(git -C "$ROOT" rev-parse --abbrev-ref '@{u}' 2>/dev/null || echo origin/master)"
git -C "$ROOT" merge --ff-only "$UPSTREAM" \
  || die "clone at $ROOT has diverged from $UPSTREAM — run 'chezmoi update' or re-clone; not touching it automatically."
exec chezmoi apply
