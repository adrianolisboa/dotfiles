#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
PRE_PUSH_HOOK="$HOOKS_DIR/pre-push"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

mkdir -p "$HOOKS_DIR"

cat > "$PRE_PUSH_HOOK" <<'HOOK'
#!/usr/bin/env bash

set -euo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "pre-push: gitleaks is required. Install with: brew install gitleaks" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"

scan_range() {
  local range="$1"
  gitleaks git "$REPO_ROOT" \
    --log-opts "$range" \
    --no-banner \
    --redact=100 \
    --exit-code 1
}

has_refs=0
while read -r local_ref local_sha remote_ref remote_sha; do
  has_refs=1

  # Skip deleted refs.
  if [[ "$local_sha" =~ ^0+$ ]]; then
    continue
  fi

  if [[ "$remote_sha" =~ ^0+$ ]]; then
    # New branch push: scan commits reachable from local head.
    if ! scan_range "$local_sha"; then
      echo "pre-push: gitleaks found potential secrets in ref $local_ref." >&2
      exit 1
    fi
  else
    if ! scan_range "${remote_sha}..${local_sha}"; then
      echo "pre-push: gitleaks found potential secrets in ref $local_ref." >&2
      exit 1
    fi
  fi
done

# Fallback when stdin is empty (manual hook invocation).
if (( has_refs == 0 )); then
  gitleaks dir "$REPO_ROOT" --no-banner --redact=100 --exit-code 1
fi
HOOK

chmod +x "$PRE_PUSH_HOOK"
echo "Installed pre-push hook: $PRE_PUSH_HOOK"

# Non-blocking reminder: keep MIGRATION.md / README.md in sync with managed config.
cat > "$PRE_COMMIT_HOOK" <<'HOOK'
#!/usr/bin/env bash

set -euo pipefail

staged="$(git diff --cached --name-only)"

# Paths whose changes may affect how a new Mac is set up.
config_re='^(zsh/|git/|tmux/|input/|nvim/|gh/|osx-conf/|scripts/|config/macforge\.sh|bootstrap\.sh)'
docs_re='^(MIGRATION\.md|README\.md)$'

if grep -qE "$config_re" <<<"$staged" && ! grep -qE "$docs_re" <<<"$staged"; then
  echo "⚠ macforge: you changed managed config but not MIGRATION.md / README.md." >&2
  echo "  If this changes how a new Mac is set up, update them too (see AGENTS.md)." >&2
  echo "  (reminder only — commit proceeds)" >&2
fi

exit 0
HOOK

chmod +x "$PRE_COMMIT_HOOK"
echo "Installed pre-commit hook: $PRE_COMMIT_HOOK"
