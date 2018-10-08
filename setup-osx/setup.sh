#!/usr/bin/env bash

###############################################################################
# OSX Basic Configuration                                                     #
###############################################################################

echo "Setting OSX basic configurations"

sh basic-configuration.sh

###############################################################################
# Homebrew setup                                                              #
###############################################################################

read -p "Install homebrew and its dependencies? (y or n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    # Install Homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # Install Dependencies
    brew bundle
fi
