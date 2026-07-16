# vim: ft=zsh sw=2 ts=2 expandtab

# macforge loader: aliases, common, functions, optional modules
LOAD_ROOT="$HOME/Projects/macforge/osx-conf"
. "${LOAD_ROOT}/load"

# fzf
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"

# zoxide — smarter cd: `z <name>` jumps by frecency, `zi` picks interactively.
# Coexists with the gg function; retire gg once zoxide has learned your dirs. Guarded: no-ops until installed.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# atuin — shell history across all panes (sync off by default). Ctrl-R only; keeps normal up-arrow.
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"

# PATH (highest priority first)
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.mix/escripts:$PATH"

# OpenSSL 1.1 build flags
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"

# Erlang build flag
export KERL_CONFIGURE_OPTIONS="--disable-jit"

# Completions (guarded: only run when the tool is present)
command -v colima >/dev/null 2>&1 && eval "$(colima completion zsh)"

# safe-chain
[[ -f "$HOME/.safe-chain/scripts/init-posix.sh" ]] && source "$HOME/.safe-chain/scripts/init-posix.sh"

# Machine-local overrides (work env, secrets, per-machine paths)
[[ -f "$HOME/.config/macforge/secrets.zsh" ]] && source "$HOME/.config/macforge/secrets.zsh"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
