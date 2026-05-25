#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  echo "missing dependency: nvim" >&2
  exit 127
fi

export XDG_STATE_HOME="${XDG_STATE_HOME:-${TMPDIR:-/tmp}/codex-nvim-state}"
mkdir -p "$XDG_STATE_HOME"

printf '== nvim version ==\n'
nvim --version | sed -n '1,5p'

printf '\n== headless startup ==\n'
nvim --headless '+qa'

printf '\n== checkhealth ==\n'
nvim --headless '+checkhealth' '+qa'
