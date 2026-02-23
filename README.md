[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/adrianolisboa)

This repository contains dotfiles managed with GNU Stow.

### Install on a fresh macOS machine (2026)

```bash
git clone git@github.com:adrianolisboa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` will:
- Ensure Homebrew is installed.
- Install GNU Stow if needed.
- Back up conflicting existing files to `~/.dotfiles-backup/<timestamp>/`.
- Symlink all managed packages (`git`, `bash`, `input`, `tmux`) into `$HOME`.

### Manual usage

```bash
cd ~/dotfiles
stow --target "$HOME" git bash input tmux
```
