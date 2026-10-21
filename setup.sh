#!/usr/bin/env bash
# Build the demo repo and an isolated Codex home with memories turned on.
# Usage: bash setup.sh [repo_dir] [codex_home]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="${1:-$HOME/cse598-memory-demo}"
home="${2:-$HOME/.codex-memory-demo}"

if [ -e "$repo" ]; then
  echo "$repo already exists; remove it first" >&2
  exit 1
fi
cp -r "$here/template" "$repo"
git -C "$repo" init -q
git -C "$repo" add -A
git -C "$repo" -c user.name=demo -c user.email=demo@example.com commit -qm "day0: starting point"
git -C "$repo" tag day0

# A separate CODEX_HOME keeps the demo's memories out of your own ~/.codex.
mkdir -p "$home"
if [ ! -f "$home/auth.json" ] && [ -f "$HOME/.codex/auth.json" ]; then
  cp "$HOME/.codex/auth.json" "$home/auth.json"
  chmod 600 "$home/auth.json"
fi
# Phase 1 keeps the default 6-hour idle threshold (config can lower it to 1 h,
# not below); skip_idle_wait.sh skips the wait instead.
if [ ! -f "$home/config.toml" ]; then
  cat > "$home/config.toml" <<TOML
[features]
memories = true
TOML
fi

echo "repo:       $repo"
echo "CODEX_HOME: $home"
echo "next:       export CODEX_HOME=$home; cd $repo; codex"
