# shellcheck shell=bash

hookrail_fallback_output() {
  local input_json event_name cue_dir message_json

  input_json="${1:-}"
  event_name=""
  if [[ -n "$input_json" && -f "$input_json" ]]; then
    event_name="$(jq -r '.hook_event_name // empty' "$input_json" 2>/dev/null || true)"
  fi

  cue_dir="$(hookrail_cue_dir)"
  if [[ -d "$cue_dir" ]] && command -v cue >/dev/null 2>&1; then
    if (cd "$cue_dir" && cue export . -e '#SafeFallback' --out json) 2>/dev/null; then
      return 0
    fi
  fi

  message_json="$(hookrail_json_string "hookrail safe fallback after adapter/CUE failure")"
  if [[ "$event_name" == "PostToolUse" ]]; then
    printf '{"continue":true,"systemMessage":%s}\n' "$message_json"
  else
    printf '{"continue":true,"suppressOutput":true,"systemMessage":%s}\n' "$message_json"
  fi
}
