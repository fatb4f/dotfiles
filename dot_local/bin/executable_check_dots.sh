#!/usr/bin/env bash
set -euo pipefail

state_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/chezmoi-drift"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
out="$state_root/$stamp"

mkdir -p "$out"

# 1. Source repo state: is tracked chezmoi source clean?
chezmoi git -- status --short >"$out/source-git-status.txt"

# 2. Managed surface: what live paths are under chezmoi authority?
chezmoi managed \
  --include=files,symlinks \
  --path-style=absolute \
  >"$out/managed-paths.txt"

# 3. Summary drift signal.
chezmoi status >"$out/status.txt" || true

# 4. Full evidence patch: target state vs live destination state.
chezmoi diff --exclude=scripts >"$out/diff.patch" || true

# 5. Machine gate.
if chezmoi verify --exclude=scripts >"$out/verify.out" 2>"$out/verify.err"; then
  verdict="clean"
else
  verdict="drift"
fi

cat >"$out/report.json" <<EOF
{
  "schema": "dotfiles.chezmoi.drift.v1",
  "timestamp_utc": "$stamp",
  "verdict": "$verdict",
  "artifacts": {
    "source_git_status": "$out/source-git-status.txt",
    "managed_paths": "$out/managed-paths.txt",
    "status": "$out/status.txt",
    "diff": "$out/diff.patch",
    "verify_stdout": "$out/verify.out",
    "verify_stderr": "$out/verify.err"
  }
}
EOF

printf '%s\n' "$out/report.json"
