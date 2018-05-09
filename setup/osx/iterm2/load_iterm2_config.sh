#!/bin/bash

directory=$( dirname "${BASH_SOURCE[0]}" )

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $directory

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

