#!/usr/bin/env bash
set -euo pipefail

# Re-applies whenever this script changes.
echo "[macos_defaults] applying..."
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' || true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write com.apple.dock autohide -bool true
killall Dock >/dev/null 2>&1 || true
echo "[macos_defaults] done"
