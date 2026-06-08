#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
payload="$(cat)"
cue cmd -t hook="$payload" validate ./.codex
