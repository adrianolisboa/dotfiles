# Neovim Configuration

A clean, modular Neovim setup using `lazy.nvim` for plugin management.

This config is part of [macforge](../../../README.md) and is stowed to
`~/.config/nvim`. You don't clone it separately — running `./macforge setup`
symlinks it into place. Edit the files here in the repo, not in `~/.config/nvim`
(that path is a symlink back to this directory).

## Layout

```
init.lua                 -- entry point (loads settings + plugins)
lazy-lock.json           -- pinned plugin versions (committed for reproducibility)
lua/settings/            -- options, keymaps, autocommands
lua/plugins/init.lua     -- lazy.nvim plugin list
lua/plugins/specs/       -- per-plugin config (lsp, telescope, conform, ...)
```

## First launch

After `./macforge setup` has symlinked the config, `lazy.nvim` bootstraps itself
on first launch. Just open Neovim and let it install:

```bash
nvim
# inside Neovim, if needed:
# :Lazy sync
```

## AI plugin

Uses [`claudecode.nvim`](https://github.com/coder/claudecode.nvim) (Claude Code
integration). Keymaps under `<leader>c*` — see `lua/plugins/specs/claudecode.lua`.

## Required font

Works best with a Nerd Font (e.g. FiraCode Nerd Font):

```bash
brew install --cask font-fira-code-nerd-font
```

Then set your terminal to "FiraCode Nerd Font" (or "… Mono").
