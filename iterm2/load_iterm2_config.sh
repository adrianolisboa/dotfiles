#!/usr/bin/env bash

dir=$(pwd)

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string dir

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
