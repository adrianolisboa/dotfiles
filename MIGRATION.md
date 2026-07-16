# New Mac Migration Guide

Bootstraps a new Mac to match this one, using [chezmoi](https://www.chezmoi.io/).
Everything portable lives in this repo; anything with a secret or work identity
is **not** in the repo and is restored separately (see
[machine-local files](#3-restore-machine-local-files-not-in-the-repo)).

---

## TL;DR

One command on a brand-new Mac (installs Xcode CLT + chezmoi, then applies):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
```

Or directly:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adrianolisboa/macforge
```

chezmoi prompts "Is this a work machine?" (and, if yes, your work git name/email),
symlinks every dotfile into place, and runs the setup scripts. Then restore SSH
keys/secrets (below), `gh auth login`, and open `nvim` once for plugins.

---

## Driving this with Claude

Open Claude Code on the new Mac and paste:

> Read `MIGRATION.md` and set up this Mac with chezmoi. Do **not** invent or
> restore any secrets, SSH keys, or my work git identity — stop and tell me when
> a step needs one, and I'll provide it. After `chezmoi apply`, run
> `chezmoi doctor` and report what's still missing.

---

## 1. Prerequisites

- **macOS** (Apple Silicon assumed; paths use `/opt/homebrew`).
- **Xcode CLT** + **chezmoi** — the bootstrap one-liner installs both.
- ⚠️ **Work Mac:** a company-managed Mac may ship with **workbrew** at
  `/opt/workbrew/bin/brew`, which manages mandatory formulae. macforge's Brewfile
  is a small personal baseline and the run script uses whichever `brew` is on
  PATH — no conflict. Work-only tools (your employer's CLIs, cloud-creds helpers, …)
  are intentionally NOT in macforge; workbrew provides them.

---

## 2. Apply with chezmoi

The bootstrap one-liner runs this for you; to do it manually:

```bash
chezmoi init --apply adrianolisboa/macforge
```

What happens:

- **Prompts** "Is this a work machine?" → if yes, your work git name/email
  (stored in `~/.config/chezmoi/chezmoi.toml`, machine-local, never in the repo).
- **Symlinks** every dotfile into `$HOME` / `~/.config` (symlink mode — edit
  either side).
- **Runs the setup scripts** in order:

| Script | What it does |
|--------|--------------|
| `run_once_before_10-homebrew` | Install Homebrew if no brew present (skips if workbrew/homebrew exists) |
| `run_onchange_after_20-brewfile` | `brew bundle` from `~/.config/macforge/osx-conf/Brewfile` (re-runs when it changes) |
| `run_onchange_after_30-macos-defaults` | Dark mode, key repeat, Finder, Dock autohide |
| `run_once_after_40-iterm2` | Point iTerm2 at the tracked prefs folder |
| `run_once_after_50-git-hooks` | Install gitleaks pre-push + docs-sync pre-commit |

Useful:

```bash
chezmoi diff                     # preview before applying
chezmoi apply --exclude=scripts  # dotfiles only (skip brew/defaults)
chezmoi doctor                   # health check
chezmoi update                   # git pull + apply (sync from another machine)
brew bundle --file ~/.config/macforge/osx-conf/Brewfile.optional   # optional tools
```

Edit a managed file directly (it's a symlink into the repo) or via
`chezmoi edit ~/.zshrc`; push from the source with `chezmoi cd` + `git push`.

---

## 3. Restore machine-local files (NOT in the repo)

Kept out of git deliberately. Transfer securely (1Password / regenerate); never commit.

| What | How to restore |
|------|----------------|
| **SSH keys + git signing** | Best: enable the **1Password SSH agent** (1Password → Settings → Developer → "Use the SSH Agent") — keys stay in 1Password, nothing to copy, signs commits too. Fallback: copy `~/.ssh/adriano_github`, `github_personal`, `id_ed25519`, `id_ed25519_gitlab` (+ `.pub`), `chmod 600` the private keys. |
| **Secrets / tokens** | Recommended: `cp ~/.config/macforge/osx-conf/secrets.env.example ~/.config/macforge/secrets.env`, fill in `op://` references, run tools via `oprun`. Legacy: restore `~/.config/macforge/secrets.zsh` (chmod 600). |
| **Work git identity** | Answer "work machine? = yes" at `chezmoi init` and it renders `~/.gitconfig-professional` from your prompt answers. (Or restore the file by hand.) |

If you use plain SSH key files (not the 1Password agent), the shell auto-runs
`ssh-add ~/.ssh/adriano_github` on first login — make sure that key exists (or
update the name in `osx-conf/common/exports`).

---

## 4. GitHub / GitLab CLI auth

```bash
gh auth login    # writes ~/.config/gh/hosts.yml (real local file, not in the repo)
```

`glab` is a work tool, intentionally not tracked — install/auth separately if needed.

---

## 5. Neovim + shell history

```bash
nvim                                        # lazy.nvim bootstraps + installs plugins
brew install --cask font-fira-code-nerd-font # Nerd Font for icons
atuin import auto                            # import existing shell history (atuin starts empty)
```

Set the terminal font to "FiraCode Nerd Font". atuin config (searches all
history, local-only) is managed by macforge.

---

## 6. Apps to reinstall manually (optional)

The Brewfile installs the personal CLI baseline + these casks (1password-cli,
font-inter, macdown, ngrok, notunes, wkhtmltopdf). Anything else you want
(ChatGPT, work apps via MDM/workbrew, etc.) reinstall as needed.

---

## 7. Verify

```bash
chezmoi doctor
ls -la ~/.zshrc ~/.config/nvim/init.lua ~/.config/gh/config.yml   # symlinks into ~/.local/share/chezmoi
git -C ~/Projects config --get user.email                          # work email if work machine
zsh -ic 'alias gco'                                                # aliases loaded
nvim --headless -c 'lua print("ok")' -c 'quit'                     # nvim loads
```
