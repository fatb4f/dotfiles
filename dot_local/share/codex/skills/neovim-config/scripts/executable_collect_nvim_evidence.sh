#!/usr/bin/env bash
set -euo pipefail

out="${1:-./nvim-evidence}"
mkdir -p "$out"

if ! command -v nvim >/dev/null 2>&1; then
  echo "missing dependency: nvim" >&2
  exit 127
fi

export XDG_STATE_HOME="${XDG_STATE_HOME:-${TMPDIR:-/tmp}/codex-nvim-state}"
mkdir -p "$XDG_STATE_HOME"

nvim --version > "$out/nvim-version.txt"
nvim --startuptime "$out/startuptime.log" +qa || true
nvim --headless '+checkhealth' '+qa' > "$out/checkhealth.txt" 2>&1 || true

if [ -f lazy-lock.json ]; then
  cp lazy-lock.json "$out/lazy-lock.json"
fi

if [ -f init.lua ]; then
  cp init.lua "$out/init.lua"
fi

find . \
  -path './.git' -prune -o \
  -path './.local' -prune -o \
  -path './node_modules' -prune -o \
  -path './.cache' -prune -o \
  \( -path './lua/*.lua' -o -path './lua/**/*.lua' -o -path './after/**/*.lua' \) \
  -type f \
  -print | sort > "$out/lua-files.txt"

printf 'wrote evidence to %s\n' "$out"
