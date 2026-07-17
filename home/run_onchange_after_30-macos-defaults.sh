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

# Free up Ctrl-Space for the tmux prefix. By default macOS binds it to
# "Select the previous input source" (symbolic hotkey 60), and Ctrl-Opt-Space
# to "Select next source" (61), which swallow the key before tmux ever sees it.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "
<dict><key>enabled</key><integer>0</integer>
<key>value</key><dict>
<key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array>
<key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "
<dict><key>enabled</key><integer>0</integer>
<key>value</key><dict>
<key>parameters</key><array><integer>32</integer><integer>49</integer><integer>786432</integer></array>
<key>type</key><string>standard</string></dict></dict>"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

echo "[macos_defaults] done"
