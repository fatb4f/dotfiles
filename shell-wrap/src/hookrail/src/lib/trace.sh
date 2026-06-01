# shellcheck shell=bash

hookrail_append_trace() {
  local input_json output_json manifest_path trace_file state_dir session_id safe_session tmp trace_input trace_wrapped

  input_json="${1:?input JSON path required}"
  output_json="${2:?output JSON path required}"
  manifest_path="${3:-}"

  state_dir="$(hookrail_state_dir)"
  session_id="$(jq -r '.session_id // "unknown-session"' "$input_json")"
  safe_session="$(hookrail_safe_component "$session_id")"
  trace_file="$state_dir/trace/$safe_session.jsonl"
  trace_input="$(mktemp "${TMPDIR:-/tmp}/hookrail-trace-input.XXXXXX.json")"
  trace_wrapped="$(mktemp "${TMPDIR:-/tmp}/hookrail-trace-wrapped.XXXXXX.json")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/hookrail-trace-row.XXXXXX.json")"

  mkdir -p "${trace_file%/*}"
  jq -c \
    --arg timestamp "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --arg manifestPath "$manifest_path" \
    '
      .hookrail = (.hookrail // {})
      | .hookrail.trace = ((.hookrail.trace // {}) + {
          timestamp: $timestamp,
          manifestPath: (if $manifestPath == "" then null else $manifestPath end)
        })
    ' "$input_json" >"$trace_input"
  hookrail_wrap_input "$trace_input" "$trace_wrapped"
  hookrail_project_trace_row "$trace_wrapped" >"$tmp"
  cat "$tmp" >>"$trace_file"
  printf '\n' >>"$trace_file"
  rm -f "$trace_input" "$trace_wrapped" "$tmp"
}

hookrail_try_append_trace() {
  hookrail_append_trace "$@" >/dev/null 2>&1 || true
}
