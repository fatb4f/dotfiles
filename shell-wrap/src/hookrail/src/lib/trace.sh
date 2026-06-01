# shellcheck shell=bash

hookrail_append_trace() {
  local input_json output_json manifest_path trace_file state_dir session_id safe_session tmp

  input_json="${1:?input JSON path required}"
  output_json="${2:?output JSON path required}"
  manifest_path="${3:-}"

  state_dir="$(hookrail_state_dir)"
  session_id="$(jq -r '.session_id // "unknown-session"' "$input_json")"
  safe_session="$(hookrail_safe_component "$session_id")"
  trace_file="$state_dir/trace/$safe_session.jsonl"
  tmp="$(mktemp "${TMPDIR:-/tmp}/hookrail-trace-row.XXXXXX.json")"

  mkdir -p "${trace_file%/*}"
  jq -n \
    --arg timestamp "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --arg manifestPath "$manifest_path" \
    --slurpfile input "$input_json" \
    --slurpfile output "$output_json" '
      ($input[0]) as $in
      | ($output[0]) as $out
      | ($in.hookrail.gitFacts // {}) as $git
      | ($out.hookSpecificOutput.additionalContext // null) as $frame
      | {
          timestamp: $timestamp,
          hookEventName: ($in.hook_event_name // null),
          sessionID: ($in.session_id // null),
          turnID: ($in.turn_id // "session"),
          cwd: ($in.cwd // null),
          model: ($in.model // null),
          transcriptPath: ($in.transcript_path // null),
          persisted: ($manifestPath != ""),
          manifestPath: (if $manifestPath == "" then null else $manifestPath end),
          git: {
            isRepo: ($git.isRepo // false),
            root: ($git.root // null),
            branch: ($git.branch // null),
            head: ($git.head // null),
            clean: (if ($git | has("clean")) then $git.clean else null end),
            counts: ($git.counts // null),
            truncated: ($git.truncated // false),
            operation: ($git.operation.state // null)
          },
          frame: {
            generated: ($frame != null),
            chars: (if $frame == null then 0 else ($frame | length) end)
          }
        }
    ' >"$tmp"
  cat "$tmp" >>"$trace_file"
  printf '\n' >>"$trace_file"
  rm -f "$tmp"
}

hookrail_try_append_trace() {
  hookrail_append_trace "$@" >/dev/null 2>&1 || true
}
