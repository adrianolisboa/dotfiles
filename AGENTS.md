# AGENTS.md — macforge

Rules for any agent (Claude Code, Cursor, Codex, …) or human working in this repo.

## What this is

`macforge` is a personal macOS bootstrap + dotfiles repo managed with
[chezmoi](https://www.chezmoi.io/). It's the **single source of truth** for
personal config across Macs. `.chezmoiroot` points chezmoi at `home/`. In
**symlink mode**, non-template files are symlinked back into the repo (edit
either side); templates/scripts are rendered. `chezmoi apply` lays down dotfiles
and runs the setup scripts (Homebrew → Brewfile → macOS defaults → iTerm2 → hooks).

## Layout

```
.chezmoiroot                       # "home"
home/
  .chezmoi.toml.tmpl               # prompts (work machine? → data), sets mode = "symlink"
  .chezmoiignore                   # skip .gitconfig-professional on non-work machines
  dot_zshrc dot_gitconfig …        # dotfiles: dot_ → ~/.  (symlinked in symlink mode)
  dot_config/{nvim,gh,atuin}       # → ~/.config/*
  dot_config/macforge/shell/       # zsh loader (load + aliases/ common/ functions/ optional/)
  dot_config/macforge/{bin,iterm2,Brewfile,Brewfile.optional,secrets.env.example}
  dot_gitconfig-professional.tmpl  # work identity, rendered from prompt data (never a secret in the repo)
  run_once_* / run_onchange_*      # setup scripts (homebrew, brewfile, macos defaults, iterm2, git-hooks)
scripts/install-git-hooks.sh       # gitleaks pre-push + docs-sync pre-commit
bootstrap.sh                       # fresh-Mac one-liner (CLT + chezmoi + init --apply)
README.md / MIGRATION.md / docs/   # human docs (kept in sync — see rules)
```

## Running / applying

```bash
chezmoi apply                        # apply everything
chezmoi apply --exclude=scripts      # files/symlinks only (skip brew/defaults scripts)
chezmoi diff                         # preview
chezmoi doctor                       # health check
chezmoi init --promptDefaults        # non-interactive (agent driving): work=false
chezmoi init                         # interactive: prompts work machine? + work email
```

On this machine, chezmoi's source is `~/.local/share/chezmoi` → symlinked to
this repo, so `chezmoi` commands work with no `--source` flag and edits/pushes
happen here.

## Golden rules

1. **Keep `MIGRATION.md` and `README.md` in sync.** If you change managed
   dotfiles, run scripts, the Brewfile, or setup behavior in a way that affects
   how a new Mac is set up, update `MIGRATION.md` (and `README.md`) in the same
   change. A pre-commit hook reminds you.
2. **No secrets, no work identity — this repo is PUBLIC.** Never commit tokens,
   API keys, a work email or employer domain, or work-only tooling
   (internal CLIs, cloud-creds helpers, work MCP certs). Machine-local & untracked:
   `~/.config/chezmoi/chezmoi.toml` (holds prompt answers incl. work email),
   `~/.config/macforge/secrets.zsh|env`, `~/.config/gh/hosts.yml`, SSH keys.
   Work-specific values belong in prompt data / 1Password templates, not literals.
3. **Symlink-mode gotcha:** anything sourced by iterating a directory must follow
   symlinks (`find -L`, not `find -type f`) — module files under
   `~/.config/macforge/shell` are symlinks.
4. **Verify before committing:** `chezmoi diff` clean/expected, shell loads,
   nvim loads (below). No `chezmoi doctor` failures.
5. **Commits:** Conventional Commits (`feat:`/`fix:`/`chore:`/`docs:` …),
   concise, lowercase, **no `Co-Authored-By`**, no `--author`.
6. **Prune to what's actually used** — check real usage (`~/.zsh_history`),
   don't guess; presence = keep, absence in a small history ≠ proof of disuse.

## Adding a new dotfile (the pattern)

chezmoi maps source names to targets by prefix:

- `~/.foorc` → `home/dot_foorc`
- `~/.config/tool/conf` → `home/dot_config/tool/conf`
- needs a template (per-machine/secret) → add `.tmpl`, use `.chezmoi.*` vars / `onepasswordRead`
- executable that ISN'T symlinked (a template) → prefix `executable_`
- secret the tool writes into its own dir (like `gh` `hosts.yml`) → gitignore it

Then `chezmoi apply`, verify, and update `MIGRATION.md` + `README.md`.

## Verify like an agent

- `chezmoi diff` shows only intended changes; `chezmoi apply` is clean.
- Test on a scratch home before real machines:
  `HOME=/tmp/x chezmoi init --source="$PWD" --promptDefaults && HOME=/tmp/x chezmoi apply --source="$PWD" --exclude=scripts`
- Shell loads: `zsh -ic 'echo ok; alias gco'` (aliases present).
- Neovim loads: `nvim --headless -c 'lua print("ok")' -c 'quit'`.
