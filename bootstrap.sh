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

# 2. Install chezmoi (if needed), then bring the machine up to date.
#    chezmoi asks "Is this a work machine?" on first init, then applies everything.
#    `chezmoi init` only clones when the source is absent — it does NOT pull an
#    existing clone. So if the repo is already there, re-running this bootstrap
#    would re-apply a stale copy. Detect that case and `chezmoi update` (git pull
#    --autostash --rebase + apply) so re-runs always sync to the latest master.
if command -v chezmoi >/dev/null 2>&1; then
  SRC="$(chezmoi source-path 2>/dev/null || true)"
  if [ -n "$SRC" ] && git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1; then
    log "chezmoi source already present — pulling latest and applying (chezmoi update)"
    exec chezmoi update
  fi
  log "chezmoi present — running init --apply $GH_REPO"
  exec chezmoi init --apply "$GH_REPO"
else
  log "Installing chezmoi and applying $GH_REPO"
  exec sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$GH_REPO"
fi
