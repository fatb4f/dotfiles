# shellcheck shell=bash

hookrail_fallback_output() {
  local cue_dir message_json

  cue_dir="$(hookrail_cue_dir)"
  if [[ -d "$cue_dir" ]] && command -v cue >/dev/null 2>&1; then
    if (cd "$cue_dir" && cue export . -e '#SafeFallback' --out json) 2>/dev/null; then
      return 0
    fi
  fi

  message_json="$(hookrail_json_string "hookrail safe fallback after adapter/CUE failure")"
  printf '{"continue":true,"suppressOutput":true,"systemMessage":%s}\n' "$message_json"
}
