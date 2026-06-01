#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  echo "missing dependency: nvim" >&2
  exit 127
fi

status=0
while IFS= read -r file; do
  if ! FILE="$file" nvim --headless -u NONE -i NONE -n --cmd 'set shadafile=NONE' \
    -c 'lua local f, err = loadfile(vim.env.FILE); if not f then vim.api.nvim_err_writeln(err); vim.cmd("cquit 1") end' +qa; then
    echo "lua syntax error: $file" >&2
    status=1
  fi
done < <(find . \
  -path './.git' -prune -o \
  -path './node_modules' -prune -o \
  -path './.cache' -prune -o \
  -name '*.lua' -type f -print | sort)

exit "$status"
