# macforge

Personal macOS bootstrap + dotfiles + shell tooling, managed with
[chezmoi](https://www.chezmoi.io/). Dotfiles live under `home/` in chezmoi's
source format and are applied with `chezmoi apply`. In **symlink mode**, managed
files become symlinks back into this repo, so you can edit either side — while
still getting templating, per-machine config, and setup scripts.

## Fresh Mac — one command

On a brand-new Mac (installs Xcode CLT, installs chezmoi, then clones + applies):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
```

Or directly with chezmoi:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adrianolisboa/macforge
```

chezmoi asks "Is this a work machine?" (and, if yes, your work git name/email),
lays down every dotfile, then runs the setup scripts (Homebrew, Brewfile, macOS
defaults, iTerm2, git hooks).

## Working in this repo

Agent + contributor rules (including "keep MIGRATION.md in sync") live in
[AGENTS.md](AGENTS.md). New-Mac migration steps live in [MIGRATION.md](MIGRATION.md).

## Layout

```
.chezmoiroot                 → "home" (chezmoi's source root)
home/
  .chezmoi.toml.tmpl         prompts (work machine?) + symlink mode
  .chezmoiignore             skip work identity on non-work machines
  dot_zshrc, dot_gitconfig…  dotfiles (dot_ → ~/.)
  dot_config/nvim, gh, atuin, macforge/osx-conf   → ~/.config/*
  dot_gitconfig-professional.tmpl                 work identity (rendered from prompt)
  run_once_* / run_onchange_*                     setup scripts
scripts/install-git-hooks.sh                      gitleaks + docs-sync hooks
docs/                                             plans/notes
```

## Everyday commands

```bash
chezmoi apply                 # apply changes (symlinks + templates + scripts)
chezmoi diff                  # preview what would change
chezmoi edit ~/.zshrc         # edit a managed file's source (or just edit ~/.zshrc — it's a symlink)
chezmoi cd                    # shell in the source repo
chezmoi update                # git pull + apply
chezmoi doctor                # health check
chezmoi init                  # re-run prompts (e.g. to flip work machine)
```

## Brewfile

- `home/dot_config/macforge/osx-conf/Brewfile` → applied to `~/.config/macforge/osx-conf/Brewfile`.
- A `run_onchange` script re-runs `brew bundle` automatically whenever it changes.
- Optional set: `brew bundle --file ~/.config/macforge/osx-conf/Brewfile.optional`.

## Shell configuration

`~/.zshrc` sources `~/.config/macforge/osx-conf/load`, which pulls in everything
under `osx-conf/{aliases,common,functions,optional}`. Machine-local/private
config belongs in `~/.config/macforge/secrets.zsh` (sourced at the end if present).

## Neovim

Applied to `~/.config/nvim` (lazy.nvim, LSP, telescope, conform, claudecode.nvim);
`lazy.nvim` bootstraps itself on first launch. See `home/dot_config/nvim/README.md`.

## gh (GitHub CLI)

`config.yml` is managed; the auth token in `~/.config/gh/hosts.yml` is **not**
tracked — run `gh auth login` per machine.

## Secrets

**Recommended — 1Password references (no plaintext on disk).** Fill in `op://`
references and run tools through the `oprun` helper:

```bash
cp ~/.config/macforge/osx-conf/secrets.env.example "$HOME/.config/macforge/secrets.env"
# edit it: VAR=op://Vault/Item/field   (Copy Secret Reference from the 1Password app)
oprun mix phx.server        # secrets injected at runtime, nothing on disk
```

**Legacy — machine-local file:** `~/.config/macforge/secrets.zsh` (chmod 600), sourced by `.zshrc`.

## Work / professional git identity

On `chezmoi init`, answering "work machine? = yes" prompts for your work git
name/email; `~/.gitconfig-professional` is then rendered from those answers
(stored machine-locally in `~/.config/chezmoi/chezmoi.toml`, never in the repo).
On non-work machines the file is skipped. `~/.gitconfig` includes it for repos
under `~/Projects/`.

## Syncing between computers

macforge is the source of truth. On the machine where you changed config,
`git push` from the source (`chezmoi cd`). On another machine, `chezmoi update`
(git pull + apply).

## Git hooks

```bash
./scripts/install-git-hooks.sh   # or the run_once script does it on first apply
```

- **pre-push** — `gitleaks`; blocks the push if secrets are detected.
- **pre-commit** — non-blocking reminder to update `MIGRATION.md` / `README.md` when managed config changes.
