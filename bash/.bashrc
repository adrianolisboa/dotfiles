set -o vi
set -o ignoreeof

how() {
  claude --model haiku -p "Answer concisely and briefly: how $*"
}
