# mac-dev-kit

Single repository for:
- Dotfiles managed with GNU Stow.
- macOS bootstrap/setup scripts and shell environment (`osx-conf/`).

Recommended new repository name: `mac-dev-kit`.

### Install on a fresh macOS machine (2026)

```bash
git clone git@github.com:adrianolisboa/dotfiles.git ~/mac-dev-kit
cd ~/mac-dev-kit
./install.sh
```

`install.sh` will:
- Ensure Homebrew is installed.
- Install GNU Stow if needed.
- Back up conflicting existing files to `~/.dotfiles-backup/<timestamp>/`.
- Symlink all managed packages (`git`, `bash`, `input`, `tmux`) into `$HOME`.

### Manual dotfiles usage

```bash
cd ~/mac-dev-kit
stow --target "$HOME" git bash input tmux
```

### Shell loader (from merged `osx-conf`)

Add this to your `.zshrc`:

```zsh
LOAD_ROOT="$HOME/mac-dev-kit/osx-conf"
. ${LOAD_ROOT}/load
```

### macOS setup (2026-ready)

```zsh
cd "$HOME/mac-dev-kit/osx-conf"
./setup.sh
```
