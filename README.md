## Environment Setup

This repository contains everything that I need to setup a new environment. Like my `dotfiles` and `setup` files for each env.

Every folder have a `.sh` file that need to been executed depeending on our environment.
You can execute they using `./name_of_file.sh`.

### Clonning

Clone the repository on your home folder (`/home/[username]`) with the name `.vim`.

    git clone https://github.com/adrianolisboa/env-setup.git ~/.env-setup

### Setup of dotfiles

Creating a link for the dotfiles
    
    ~/.env-setup/dotfiles/link.sh

### Setup of the environment

According to our SO run:

    ~/.env-setup/setup/[our so]/setup.sh
