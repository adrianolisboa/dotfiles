#!/bin/bash

rm -f ~/.bashrc ~/.inputrc 

ln -s .env-setup/dotfiles/bashrc ~/.bashrc
ln -s .env-setup/dotfiles/inputrc ~/.inputrc
