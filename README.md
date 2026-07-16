# macforge

Personal macOS bootstrap + dotfiles + shell tooling in one place.

Stow packages: `git`, `zsh`, `input`, `tmux`, `nvim`, `gh`. One `./macforge setup`
symlinks all of them, installs Homebrew tools, and applies macOS defaults.

## Fresh Mac — one command

On a brand-new Mac (installs Xcode CLT, clones this repo, runs setup):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/adrianolisboa/macforge/master/bootstrap.sh)
```

Already cloned:

```bash
cd "$HOME/Projects/macforge"
./macforge setup
```

That command orchestrates all phases, saves progress, and can pause between phases.

## Working in this repo

Agent + contributor rules (including "keep MIGRATION.md in sync") live in
[AGENTS.md](AGENTS.md). New-Mac migration steps live in [MIGRATION.md](MIGRATION.md).

## Setup behavior

- Runs in phases (`xcode_clt`, `homebrew`, `stow`, `backup`, `migrate_legacy`, `apply_dotfiles`, `brew_bundle`, `macos_defaults`, `iterm2`).
- Saves state at `~/.local/state/macforge/setup.state`.
- If interrupted, re-run the same command to resume.
- Prompts before moving to the next phase (use `--yes` for non-interactive mode).

## Useful commands

```bash
./macforge help
./macforge phases
./macforge doctor
./macforge hooks
./macforge setup --yes
./macforge setup --from brew_bundle
./macforge setup --until apply_dotfiles
./macforge setup --reset-state
./macforge setup --with-optional-brew
```

## Brewfile split

- `osx-conf/Brewfile`: core baseline tools.
- `osx-conf/Brewfile.optional`: optional/legacy tools.
- Optional tools are installed only with `--with-optional-brew` (or `MACFORGE_INSTALL_OPTIONAL_BREW=1`).

## Shell configuration

macforge stows `zsh/.zshrc` to `~/.zshrc`. The template sources `osx-conf/load`, which pulls in everything under `osx-conf/{aliases,common,functions,optional}`. Machine-local/private config belongs in `~/.config/macforge/secrets.zsh` (sourced at the end of the stowed `.zshrc` if present).

## Optional shell modules

Aliases for stack-specific tools (for example `terraform`) live in `osx-conf/optional` and only load when their command exists.

## Neovim

The Neovim config is stowed from `nvim/.config/nvim` to `~/.config/nvim` (lazy.nvim, LSP, telescope, conform, claudecode.nvim). It used to live in a separate `dots.nvim` repo — it's now part of macforge, so there's nothing extra to clone. `lazy.nvim` bootstraps itself on first launch. See `nvim/.config/nvim/README.md`.

## gh (GitHub CLI)

`gh/.config/gh/config.yml` is stowed to `~/.config/gh/config.yml` (aliases + git protocol only). The auth token lives in `~/.config/gh/hosts.yml`, which is **not** tracked — run `gh auth login` per machine. Stow `gh` before `gh auth login` so the tracked `config.yml` symlink wins.

## Secrets

Keep secrets out of git and out of plaintext shell exports:

```bash
mkdir -p "$HOME/.config/macforge"
touch "$HOME/.config/macforge/secrets.zsh"
chmod 600 "$HOME/.config/macforge/secrets.zsh"
```

Then place private exports in that file (for example API keys).

## Work / professional git identity

`~/.gitconfig` (stowed from `git/.gitconfig`) includes `~/.gitconfig-professional` when the repo is under `~/Projects/`. That professional file is **not** tracked in macforge — keep it as a local file per machine to avoid leaking a work email into a public repo:

```bash
cat > "$HOME/.gitconfig-professional" <<'EOF'
[user]
    name = Your Name
    email = you@work.example
    signingkey = Your Name <you@work.example>
EOF
```

`~/.gitconfig-personal` (for personal repos) stays tracked in macforge because its content is already intentionally public.

## Syncing between computers

macforge is the source of truth for your config. To keep other machines in sync:

1. **On the machine where you changed config:** commit and push macforge (e.g. `git push`).
2. **On each other machine:** pull and re-run setup so symlinks and state are updated:

   ```bash
   cd ~/Projects/macforge
   git pull
   ./macforge setup
   ```

After a `git pull`, running `./macforge setup` skips phases already completed (state is in `~/.local/state/macforge/setup.state`).

## Git hooks

```bash
./macforge hooks
```

Installs two hooks:

- **pre-push** — runs `gitleaks`; blocks the push if potential secrets are detected in the outgoing commit range.
- **pre-commit** — non-blocking reminder to update `MIGRATION.md` / `README.md` when you commit changes to managed config.
