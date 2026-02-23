#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer currently targets macOS."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
PACKAGES=(git bash input tmux)
MANAGED_FILES=(
  ".gitconfig"
  ".gitconfig-personal"
  ".gitconfig-professional"
  ".gitignore"
  ".bashrc"
  ".inputrc"
  ".tmux.conf"
)

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  echo "Installing GNU Stow..."
  brew install stow
}

backup_conflicts() {
  local ts backup_dir
  ts="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$HOME/.dotfiles-backup/$ts"
  local did_backup=0

  for f in "${MANAGED_FILES[@]}"; do
    local target="$TARGET_DIR/$f"
    if [[ -e "$target" && ! -L "$target" ]]; then
      if [[ $did_backup -eq 0 ]]; then
        mkdir -p "$backup_dir"
      fi
      mv "$target" "$backup_dir/"
      did_backup=1
      echo "Backed up existing $target -> $backup_dir/$f"
    fi
  done

  if [[ $did_backup -eq 1 ]]; then
    echo "Backups created under: $backup_dir"
  fi
}

apply_stow() {
  cd "$SCRIPT_DIR"
  echo "Applying dotfiles with Stow into $TARGET_DIR"
  stow --restow --target "$TARGET_DIR" "${PACKAGES[@]}"
}

ensure_brew
ensure_stow
backup_conflicts
apply_stow

echo "Dotfiles applied successfully."
