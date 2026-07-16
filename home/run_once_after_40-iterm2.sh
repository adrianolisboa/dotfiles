#!/usr/bin/env bash
set -euo pipefail

PLIST_DIR="$HOME/.config/macforge/iterm2"
if [ ! -f "$PLIST_DIR/com.googlecode.iterm2.plist" ]; then
  echo "[iterm2] plist missing at $PLIST_DIR — skipping"
  exit 0
fi
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$PLIST_DIR"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
echo "[iterm2] configured to load prefs from $PLIST_DIR"
