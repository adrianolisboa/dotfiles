#!/bin/bash

rm -f ~/.bashrc ~/.inputrc ~/.gitconfig ~/.gitexcludes

ln -s .env-setup/dotfiles/bashrc ~/.bashrc
ln -s .env-setup/dotfiles/inputrc ~/.inputrc
ln -s .env-setup/dotfiles/gitconfig ~/.gitconfig
ln -s .env-setup/dotfiles/gitexcludes ~/.gitexcludes
