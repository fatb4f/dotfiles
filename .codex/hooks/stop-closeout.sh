#!/usr/bin/env bash
set -euo pipefail

status="$(git status --short)"

if [ -n "$status" ]; then
  cat <<'JSON'
{
  "decision": "block",
  "reason": "Repository closeout is incomplete. Run cue cmd validate ./.codex, review git status, stage intentional files, commit, push if upstream exists, then provide closeout evidence."
}
JSON
  exit 0
fi

printf '{"continue": true}\n'
