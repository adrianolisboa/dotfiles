# New Mac Migration Guide

This guide bootstraps a new Mac to match the current one. Everything portable
lives in this repo (`macforge`); anything with a secret or a work identity is
**not** in the repo and must be restored separately (see
[Restore machine-local files](#3-restore-machine-local-files-not-in-the-repo)).

macforge now includes the Neovim config too (it used to be a separate
`dots.nvim` repo), so there is nothing else to clone.

---

## TL;DR

One command on a brand-new Mac (installs Xcode CLT, clones macforge, runs setup):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
```

Or manually:

```bash
mkdir -p "$HOME/Projects" && cd "$HOME/Projects"
git clone git@github.com:adrianolisboa/macforge.git   # or https:// if no key yet
cd macforge
./macforge setup
```

Then restore the machine-local files (SSH keys, secrets, work git identity),
run `gh auth login`, and open `nvim` once to let plugins install. Details below.

---

## Driving this with Claude

Open Claude Code in `~/Projects/macforge` on the new Mac and paste:

> Read `MIGRATION.md` and set up this Mac. Run `./macforge setup` phase by
> phase, pausing so I can confirm. Do **not** invent or restore any secrets,
> SSH keys, or my work git identity — stop and tell me when a step needs one,
> and I'll provide it. After setup, run `./macforge doctor` and report what's
> still missing.

Claude can run the phases and verification, but it must **not** fabricate
secrets. The [machine-local files](#3-restore-machine-local-files-not-in-the-repo)
are things only you can provide.

---

## 1. Prerequisites

- **macOS** (Apple Silicon assumed; paths use `/opt/homebrew`).
- **Xcode Command Line Tools** — the setup installs these in its first phase.
- **Homebrew** — the setup installs it if missing.
  - ⚠️ **Work Mac note:** if this is a Remote-managed Mac, it likely ships with
    **workbrew** at `/opt/workbrew/bin/brew`, which manages the company's
    mandatory formulae. That's separate from macforge. macforge's Brewfile only
    installs a small personal CLI baseline. If you hit a "conflicting Homebrew
    wrapper" error, run brew through whichever install your shell env points at
    and let workbrew own its own set.
- An SSH key registered with GitHub, **or** clone over HTTPS for the first pull.

---

## 2. Run macforge setup

```bash
cd ~/Projects/macforge
./macforge setup           # interactive; prompts between phases
# ./macforge setup --yes   # non-interactive
```

Phases, in order:

| Phase | What it does |
|-------|--------------|
| `xcode_clt` | Installs Xcode Command Line Tools |
| `homebrew` | Installs Homebrew if missing |
| `stow` | Installs GNU Stow |
| `backup` | Backs up any conflicting real files to `~/.dotfiles-backup/<ts>/` |
| `migrate_legacy` | Fixes up any stale symlinks |
| `apply_dotfiles` | Stows `git zsh input tmux nvim gh` → symlinks into `$HOME` and `~/.config` |
| `brew_bundle` | Installs `osx-conf/Brewfile` (add `--with-optional-brew` for the optional set) |
| `macos_defaults` | Dark mode, key repeat, Finder tweaks, Dock autohide |
| `iterm2` | Points iTerm2 at the tracked prefs folder |

State is saved to `~/.local/state/macforge/setup.state`; re-running resumes
where it left off. Useful flags:

```bash
./macforge setup --with-optional-brew    # openconnect, pass, thefuck, prettyping, the_silver_searcher
./macforge setup --from brew_bundle       # resume from a phase
./macforge doctor                         # health check
```

After stow, your dotfiles are symlinks back into this repo. Edit files **here**,
not in `~` — e.g. `~/.config/nvim` is a symlink to `nvim/.config/nvim`.

---

## 3. Restore machine-local files (NOT in the repo)

These hold secrets or a work identity, so they are deliberately kept out of git.
Transfer them securely (1Password, encrypted transfer, or regenerate) — never
commit them.

| What | Path | How to restore |
|------|------|----------------|
| **SSH keys + git signing** | 1Password (recommended) or `~/.ssh/*` | Best: enable the **1Password SSH agent** (1Password → Settings → Developer → "Use the SSH Agent") — keys stay in 1Password, nothing to copy, and it signs commits too. Fallback: copy `~/.ssh/adriano_github`, `github_personal`, `id_ed25519`, `id_ed25519_gitlab` (+ `.pub`) and `chmod 600` the private keys. |
| **Secrets / tokens** | `~/.config/macforge/secrets.env` (refs) or `secrets.zsh` (legacy) | Recommended: `cp osx-conf/secrets.env.example ~/.config/macforge/secrets.env`, fill in `op://` references, run tools via `oprun`. Legacy: restore `secrets.zsh` (chmod 600), sourced by `.zshrc`. |
| **Work git identity** | `~/.gitconfig-professional` | Recreate by hand (holds your work name/email). Auto-included for repos under `~/Projects/`. Template below. |

If you use plain SSH key files (not the 1Password agent), the shell auto-runs
`ssh-add ~/.ssh/adriano_github` on first interactive login; make sure that key
exists (or update the name in `osx-conf/common/exports`).

**`~/.gitconfig-professional` template** (fill in your real work values):

```ini
[user]
    name = Your Name
    email = you@work.example
    signingkey = Your Name <you@work.example>
```

---

## 4. GitHub / GitLab CLI auth

The tracked `gh` config carries only aliases + protocol; the token is not in the
repo. Authenticate per machine:

```bash
gh auth login          # writes ~/.config/gh/hosts.yml (a real local file, stays out of the repo)
```

`glab` (GitLab CLI) is a work tool and is intentionally **not** tracked here.
Install and authenticate it separately if you need it for work.

---

## 5. Neovim first launch

```bash
nvim        # lazy.nvim bootstraps itself, then installs plugins
# if needed: :Lazy sync
```

Install a Nerd Font for icons:

```bash
brew install --cask font-fira-code-nerd-font
```

Then set the terminal font to "FiraCode Nerd Font" (or "… Mono").

---

## 6. Apps to reinstall manually (optional checklist)

macforge installs CLI tools only. These GUI apps / casks were on the old Mac —
reinstall whatever you still want (many arrive via work MDM/workbrew on a work
Mac):

- 1Password CLI (`1password-cli`)
- ChatGPT (`chatgpt`), Chatty (`chatty`)
- Fonts: `font-inter`, `font-fira-code-nerd-font`
- MacDown (`macdown`)
- ngrok (`ngrok`)
- noTunes (`notunes`)
- AWS session-manager-plugin (`session-manager-plugin`)
- wkhtmltopdf (`wkhtmltopdf`)

---

## 7. Verify

```bash
./macforge doctor
```

Quick manual checks:

```bash
ls -la ~/.zshrc ~/.gitconfig ~/.config/nvim ~/.config/gh    # should be symlinks into ~/Projects/macforge
git config --includes --get user.email                       # in a ~/Projects repo, should show your work email (from the local professional file)
ssh-add -l                                                   # your github key should be loaded
nvim --headless -c 'lua print("ok")' -c 'quit'               # nvim loads clean
```

If `~/.config/gh` ended up as a full symlink into the repo (rather than a real
dir with `config.yml` symlinked inside it), remove it and re-run
`./macforge setup --from apply_dotfiles` — the setup pre-creates `~/.config/gh`
so `gh auth login` never writes your token into the repo.
