#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

if ! command -v cue >/dev/null 2>&1; then
  echo "blocked: cue is required for .codex workflow constraints, but was not found on PATH" >&2
  exit 2
fi

stdin_file="$(mktemp)"
stderr_file="$(mktemp)"
cleanup() {
  rm -f "$stdin_file" "$stderr_file"
}
trap cleanup EXIT

cat > "$stdin_file"

if ! cue cmd preToolUse .codex < "$stdin_file" > /dev/null 2> "$stderr_file"; then
  cat "$stderr_file" >&2
  exit 2
fi
