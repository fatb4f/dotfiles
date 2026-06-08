#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
payload="$(cat)"
if ! cue cmd -t hook="$payload" validate ./.codex; then
	exit 2
fi
