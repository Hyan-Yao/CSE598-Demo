#!/usr/bin/env bash
# Put the demo repo back to its day0 state, so the rounding rule exists only in memory.
set -euo pipefail
repo="${1:-$HOME/cse598-memory-demo}"
git -C "$repo" reset -q --hard day0
git -C "$repo" clean -qfdx
git -C "$repo" log --oneline -1
