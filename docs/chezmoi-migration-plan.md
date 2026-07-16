# Migration plan: GNU Stow → chezmoi

Status: **proposal / decide later.** macforge works fine on stow today; this is the
plan for *if/when* we decide chezmoi's extra capabilities are worth the switch.

## TL;DR

chezmoi buys three things stow can't: a genuine **one-command bootstrap**,
**per-machine config from a single source** (work vs personal), and **secrets
pulled from 1Password at apply time** (so even the work git identity has no real
value in the repo). The cost is a **copy-not-symlink** editing model and a
**Go-template** learning curve. Recommendation: **trial it in parallel** (new
branch, test on a scratch `$HOME` or the new Mac first) — don't big-bang cut over
a working setup.

---

## Benefits (why it might be worth it)

1. **True one-command new-Mac setup.**
   `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply adrianolisboa`
   installs chezmoi, clones the repo, lays down every dotfile, runs the setup
   scripts, and pulls secrets from 1Password — in one line. Replaces
   `bootstrap.sh` + `./macforge setup` + manual secret restore.

2. **One source, per-machine output.** Today "work Mac vs personal Mac"
   differences need machine-local files or shell `if` hacks. chezmoi templates
   render the *same* source file differently per machine (e.g. workbrew paths and
   work env only on the work Mac) using `{{ if .work }}…{{ end }}` — set once at
   `init` via a prompt. This is the single biggest capability stow lacks.

3. **Work identity with zero secrets in the repo.** `~/.gitconfig-professional`
   becomes a template whose work email is `{{ onepasswordRead "op://Work/git/email" }}`
   — resolved from 1Password at apply. The public repo carries the reference, not
   the value, and a new Mac fills it in automatically (no hand-recreation).

4. **Brewfile auto-reconcile.** A `run_onchange_` script re-runs `brew bundle`
   automatically whenever the Brewfile's contents change — your toolset stays in
   sync across machines without remembering to run it.

5. **Built-in per-file encryption (age)** for anything you ever want committed
   encrypted (rarely needed with 1Password, but there if you want it).

6. **Better visibility + agent-friendliness.** `chezmoi diff`, `chezmoi apply
   --dry-run`, and `chezmoi managed` show exactly what will change before it does
   — easy for you and for agents to preview. The source stays a normal git repo.

7. **No Stow dependency; single static binary**, widely adopted, good docs,
   `chezmoi doctor` for health.

## Honest tradeoffs (why not to rush)

1. **Copy, not symlink — the big one.** stow symlinks `~/.zshrc` → repo, so
   editing either side is the same file. chezmoi **copies** the rendered file into
   `$HOME`; editing `~/.zshrc` directly does *not* update the source. You edit via
   `chezmoi edit ~/.zshrc` (then `chezmoi apply`) or `chezmoi re-add`. This is the
   main day-to-day change and the thing people most often dislike.
2. **Go-template learning curve** — `.tmpl` files, `.chezmoi.*` variables,
   template functions like `onepasswordRead`.
3. **One-time conversion effort** — rename every file to chezmoi's source naming
   (`dot_`, `private_`, `.tmpl`), convert the setup phases to `run_` scripts,
   convert machine-specific bits to templates. ~half a day to a day incl. testing.
4. **Two mental models during the transition.**
5. **Workbrew:** chezmoi manages dotfiles only, so it does **not** fight workbrew
   (good). But the `run_` brew scripts must call the right brew on the work Mac.

## What changes (stow → chezmoi mapping)

| Today (stow) | chezmoi source | Applied to |
|---|---|---|
| `zsh/.zshrc` | `dot_zshrc.tmpl` | `~/.zshrc` (templated for work/personal) |
| `git/.gitconfig`, `.gitignore` | `dot_gitconfig`, `dot_gitignore` | `~/.gitconfig`, `~/.gitignore` |
| `git/.gitconfig-personal` | `dot_gitconfig-personal` | `~/.gitconfig-personal` |
| (machine-local) work identity | `dot_gitconfig-professional.tmpl` (1Password) | `~/.gitconfig-professional` |
| `input/.inputrc`, `tmux/.tmux.conf` | `dot_inputrc`, `dot_tmux.conf` | `~/.inputrc`, `~/.tmux.conf` |
| `nvim/.config/nvim/**` | `dot_config/nvim/**` | `~/.config/nvim/**` |
| `gh/.config/gh/config.yml` | `dot_config/gh/config.yml` | `~/.config/gh/config.yml` |
| `atuin/.config/atuin/config.toml` | `dot_config/atuin/config.toml` | `~/.config/atuin/config.toml` |
| `osx-conf/**` (shell loader) | `dot_config/macforge/osx-conf/**` | `~/.config/macforge/osx-conf/**` (`.zshrc` sources it there) |
| `scripts/setup-macforge.sh` phases | `run_once_` / `run_onchange_` scripts | executed on `chezmoi apply` |
| `osx-conf/Brewfile` | `dot_config/macforge/Brewfile` + `run_onchange_brew.sh` | re-runs `brew bundle` on change |
| `bootstrap.sh` | replaced by `chezmoi init --apply` + `run_once_` scripts | — |
| `macforge` CLI (setup) | replaced by `chezmoi apply` (keep a thin `doctor` wrapper if wanted) | — |
| `AGENTS.md`, `MIGRATION.md`, `README.md` | unchanged (updated for chezmoi) | — |

## Phased plan (reversible)

**Phase 0 — prep.** Keep the working stow setup as the fallback. Do this on a new
branch (`chezmoi-trial`). Confirm the goals actually apply (real work/personal
drift? want inline 1Password secrets? want the one-liner?).

**Phase 1 — scaffold.** `chezmoi init` and decide the source lives in this repo
(chezmoi can use any git repo as its source via `chezmoi init <url>`).

**Phase 2 — import dotfiles.** `chezmoi add` each managed file → generates the
`dot_*` source files. Move `osx-conf/` under `dot_config/macforge/osx-conf` and
repoint `.zshrc`'s `LOAD_ROOT` to `~/.config/macforge/osx-conf`. Add a
`.chezmoiignore` for anything not applied (docs, the CLI, Brewfile-as-source).

**Phase 3 — templatize machine differences.** Add `.chezmoi.toml.tmpl` with a
`promptBoolOnce` for "work machine?" → `.work`. Wrap work-only env/PATH in
`{{ if .work }}…{{ end }}`. Convert `~/.gitconfig-professional` to a `.tmpl`
pulling the work email from 1Password.

**Phase 4 — convert setup to run scripts.**
- `run_once_before_10-homebrew.sh.tmpl` — install CLT + Homebrew if missing.
- `run_onchange_after_20-brewfile.sh.tmpl` — `brew bundle --file …` (hash-triggered).
- `run_onchange_after_30-macos-defaults.sh` — the `defaults write` block.
- `run_once_after_40-iterm2.sh` + `run_once_after_50-git-hooks.sh` — iTerm2 prefs + install the gitleaks/docs-sync hooks.

**Phase 5 — secrets.** Keep `op run`/`oprun` for env secrets (unchanged). Use
`onepasswordRead` templates only for config files that must embed a secret.

**Phase 6 — test before touching a real machine.** `chezmoi diff` and
`chezmoi apply --dry-run`; apply into a scratch destination or a VM; verify shell
loads, nvim, git identity/signing, tools, Ctrl-R, `brew bundle`.

**Phase 7 — cut over.** Best first real use is the **new Mac**: the one-liner
above. On existing Macs, remove the stow symlinks first (`stow -D …`) then
`chezmoi init --apply` so chezmoi owns the files.

**Phase 8 — docs + cleanup.** Update `README`/`MIGRATION`/`AGENTS` for chezmoi;
retire `bootstrap.sh` and the stow bits of the `macforge` CLI once proven.

## Decision checklist

Migrate if **yes** to most:
- [ ] I have (or will have) meaningful config differences between work and personal Macs I want from one source.
- [ ] I want work secrets (git email, tokens) pulled from 1Password at apply, not recreated by hand.
- [ ] I want the literal one-command bootstrap badly enough to accept the edit-in-source model.

Stay on stow if:
- [ ] The current stow + bootstrap.sh already covers my "easy setup" need.
- [ ] I value editing `~/.zshrc` directly (symlink) over chezmoi's copy model.
