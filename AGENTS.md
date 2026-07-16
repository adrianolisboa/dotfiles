# AGENTS.md — macforge

Rules for any agent (Claude Code, Cursor, Codex, …) or human working in this repo.

## What this is

`macforge` is a personal macOS bootstrap + dotfiles repo. GNU Stow symlinks the
tracked packages into `$HOME`; `./macforge setup` runs the whole bootstrap
(Xcode CLT → Homebrew → stow → Brewfile → macOS defaults → iTerm2). It is the
**single source of truth** for personal config across Macs.

## Layout

```
macforge                 # setup CLI (setup | doctor | hooks | phases)
bootstrap.sh             # one-command fresh-Mac entry (installs CLT, clones, runs setup)
config/macforge.sh       # PACKAGES + MANAGED_FILES + Brewfile paths (edit when adding a package)
scripts/                 # setup-macforge.sh, doctor-macforge.sh, install-git-hooks.sh
zsh/ git/ tmux/ input/   # top-level dotfile packages ($HOME/.zshrc, .gitconfig, …)
nvim/ gh/                # ~/.config packages (.config/nvim, .config/gh)
osx-conf/                # shell loader: aliases/, functions/, common/, optional/, Brewfile(.optional), iterm2/
MIGRATION.md             # new-Mac guide (keep in sync — see rules)
README.md                # human overview
```

## Running setup

```bash
./macforge setup                 # interactive, phase by phase
./macforge setup --yes           # non-interactive (use this when driving as an agent)
./macforge setup --from <phase>  # resume; phases: xcode_clt homebrew stow backup
./macforge setup --with-optional-brew
./macforge doctor                # health check — MUST be 0 failures before you commit
./macforge hooks                 # install git hooks (pre-push gitleaks + pre-commit reminder)
```

## Golden rules

1. **Keep `MIGRATION.md` and `README.md` in sync.** If you change managed
   dotfiles, packages, Brewfiles, or setup behavior in a way that affects how a
   new Mac is set up, update `MIGRATION.md` (and `README.md` if the overview
   changed) in the same change. A pre-commit hook reminds you.
2. **Adding or removing a stow package** → update `PACKAGES` in
   `config/macforge.sh`. For top-level `$HOME` dotfiles, also update
   `MANAGED_FILES` (and `managed_source_path` in the setup + doctor scripts).
3. **No secrets, no work identity — this repo is PUBLIC.** Never commit tokens,
   API keys, a work email (e.g. `*@remote.com`), or work-only tooling
   (`glab`, `remotectl`, work MCP certs). These stay machine-local and untracked:
   `~/.gitconfig-professional`, `~/.config/macforge/secrets.zsh`,
   `~/.config/gh/hosts.yml`, SSH keys.
4. **Run `./macforge doctor` before committing** — it must report 0 failures.
5. **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:` …),
   concise, lowercase description, **no `Co-Authored-By`** and no `--author`.
6. **Prune to what's actually used.** When trimming aliases/tools, check real
   usage (`~/.zsh_history`) rather than guessing; presence = keep, absence in a
   small history ≠ proof of disuse.

## Adding a new dotfile or package (the pattern)

Stow mirrors a package's internal tree onto `$HOME`. Match the target path:

- **Top-level dotfile** (`~/.foorc`): put it at `zsh/.foorc`-style, i.e. a new
  package dir `foo/.foorc`, add `foo` to `PACKAGES` and `.foorc` to
  `MANAGED_FILES`.
- **Under `~/.config`** (`~/.config/tool/…`): create `tool/.config/tool/…` and
  add `tool` to `PACKAGES`. If the tool writes secrets into its config dir
  (like `gh` → `hosts.yml`), pre-create the real dir in `apply_stow` so stow
  folds only the tracked file, and gitignore the secret file.

Then: `./macforge setup --from apply_dotfiles`, verify with `./macforge doctor`,
and update `MIGRATION.md` + `README.md`.

## Verify like an agent

- `./macforge doctor` → 0 failures.
- Shell config loads: `zsh -ic 'source osx-conf/load && echo ok'`.
- Neovim loads: `nvim --headless -c 'lua print("ok")' -c 'quit'`.
- Stow structure (dry run into a temp HOME): `stow -n -v --target=/tmp/fakehome <pkg>`.
