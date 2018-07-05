#!/bin/bash

rm -f ~/.bashrc ~/.inputrc ~/.gitconfig

ln -s .env-setup/dotfiles/bashrc ~/.bashrc
ln -s .env-setup/dotfiles/inputrc ~/.inputrc
ln -s .env-setup/dotfiles/gitconfig ~/.gitconfig
