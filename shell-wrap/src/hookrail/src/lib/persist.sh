# shellcheck shell=bash

hookrail_persist_manifest() {
  local input_json manifest_json persist_json file_stem_json persist state_dir session_id turn_id safe_session safe_turn
  local file_stem safe_stem turn_dir events_dir lock_file next_seq existing base seq_text seq_value seq_name tmp final

  input_json="${1:?input JSON path required}"
  manifest_json="${2:?manifest JSON path required}"
  persist_json="${3:?persist JSON path required}"
  file_stem_json="${4:?file stem JSON path required}"

  persist="$(jq -r 'if . == true then "true" else "false" end' "$persist_json")"
  [[ "$persist" == "true" ]] || return 0

  state_dir="$(hookrail_state_dir)"
  session_id="$(jq -r '.session_id // "unknown-session"' "$input_json")"
  turn_id="$(jq -r '.turn_id // "session"' "$input_json")"
  file_stem="$(jq -r '. // "hook"' "$file_stem_json")"

  safe_session="$(hookrail_safe_component "$session_id")"
  safe_turn="$(hookrail_safe_component "$turn_id")"
  safe_stem="$(hookrail_safe_component "$file_stem")"

  turn_dir="$state_dir/runs/$safe_session/$safe_turn"
  events_dir="$turn_dir/events"
  lock_file="$turn_dir/.lock"

  mkdir -p "$events_dir"

  (
    flock -x 9

    next_seq=1
    for existing in "$events_dir"/[0-9][0-9][0-9][0-9][0-9][0-9]-*.json; do
      [[ -e "$existing" ]] || continue
      base="${existing##*/}"
      seq_text="${base%%-*}"
      seq_value="$(printf '%s\n' "$seq_text" | sed 's/^0*//')"
      [[ -n "$seq_value" ]] || seq_value=0
      ((seq_value < next_seq)) || next_seq=$((seq_value + 1))
    done

    seq_name="$(printf '%06d' "$next_seq")"
    tmp="$(mktemp "$events_dir/.tmp.$seq_name-$safe_stem.XXXXXX.json")"
    final="$events_dir/$seq_name-$safe_stem.json"

    cp "$manifest_json" "$tmp"
    (cd "$(hookrail_cue_dir)" && cue vet -c=false . "$tmp" -d '#HookManifest')
    mv "$tmp" "$final"
    printf '%s\n' "$final"
  ) 9>"$lock_file"
}

hookrail_persist_runtime_artifacts() {
  local input_json output_json event_name turn_dir lock_file tmp final

  input_json="${1:?input JSON path required}"
  output_json="${2:?output JSON path required}"
  event_name="$(jq -r '.hook_event_name // ""' "$input_json")"

  case "$event_name" in
    SessionStart|Stop) ;;
    *) return 0 ;;
  esac

  turn_dir="$(hookrail_turn_dir_from_input "$input_json")"
  lock_file="$turn_dir/.lock"
  mkdir -p "$turn_dir"

  (
    flock -x 9
    if [[ "$event_name" == "SessionStart" ]]; then
      tmp="$(mktemp "$turn_dir/.tmp.context-frame-input.XXXXXX.json")"
      final="$turn_dir/context-frame-input.json"
      jq -n \
        --arg timestamp "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --slurpfile input "$input_json" '
          ($input[0]) as $in
          | {
              schema: "hookrail.context_frame_input.v1",
              generatedAt: $timestamp,
              sessionID: ($in.session_id // "unknown-session"),
              turnID: ($in.turn_id // "session"),
              source: $in.source,
              cwd: $in.cwd,
              git: $in.hookrail.gitFacts,
              hints: ($in.hookrail.repoHints // {
                agentsPath: null,
                codexConfigPath: null,
                packageFiles: []
              })
            }
        ' >"$tmp"
      (cd "$(hookrail_cue_dir)" && cue vet -c=false . "$tmp" -d '#ContextFrameInput')
      mv "$tmp" "$final"
      printf '%s\n' "$final"
      return 0
    fi

    tmp="$(mktemp "$turn_dir/.tmp.closeout-packet.XXXXXX.json")"
    final="$turn_dir/closeout-packet.json"
    jq -n \
      --arg timestamp "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
      --slurpfile input "$input_json" \
      --slurpfile output "$output_json" '
        ($input[0]) as $in
        | ($output[0]) as $out
        | ($in.hookrail.gitFacts // {isRepo: false}) as $facts
        | {
            schema: "hookrail.closeout_packet.v1",
            generatedAt: $timestamp,
            sessionID: ($in.session_id // "unknown-session"),
            turnID: ($in.turn_id // "session"),
            cwd: $in.cwd,
            git: {
              isRepo: ($in.hookrail.git.isRepo // false),
              dirty: ($in.hookrail.git.dirty // false),
              head: ($in.hookrail.git.head // null),
              facts: $facts,
              changedFileSample: ($facts.changedSample // []),
              truncated: ($facts.truncated // false)
            },
            validation: ($in.hookrail.validation // {statuses: []}),
            stopDecisionInput: {
              commitBeforeSummary: (if ($in.hookrail.env | has("commitBeforeSummary")) then $in.hookrail.env.commitBeforeSummary else true end),
              userOptedOut: (if ($in.hookrail.env | has("userOptedOut")) then $in.hookrail.env.userOptedOut else false end),
              closeoutEvidenceExists: (if ($in.hookrail.closeout | has("evidenceExists")) then $in.hookrail.closeout.evidenceExists else false end),
              priorTraceHeadChanged: (if ($in.hookrail.closeout | has("priorTraceHeadChanged")) then $in.hookrail.closeout.priorTraceHeadChanged else false end),
              stopHookActive: (if ($in | has("stop_hook_active")) then $in.stop_hook_active else false end),
              willBlock: (($out.decision // "") == "block")
            },
            output: $out
          }
      ' >"$tmp"
    (cd "$(hookrail_cue_dir)" && cue vet -c=false . "$tmp" -d '#CloseoutPacket')
    mv "$tmp" "$final"
    printf '%s\n' "$final"
  ) 9>"$lock_file"
}

hookrail_try_persist_runtime_artifacts() {
  hookrail_persist_runtime_artifacts "$@" >/dev/null 2>&1 || true
}

hookrail_safe_component() {
  local value

  value="${1:-unknown}"
  value="${value//[^A-Za-z0-9._-]/_}"
  [[ -n "$value" ]] || value=unknown
  printf '%s\n' "$value"
}

hookrail_persist_failure_manifest() {
  local reason input_json state_dir session_id turn_id safe_session safe_turn turn_dir events_dir lock_file next_seq existing base seq_text seq_value seq_name tmp final

  reason="${1:?failure reason required}"
  input_json="${2:-}"

  [[ -n "${HOOKRAIL_STATE:-}${CODEX_STATE:-}" ]] || return 0

  state_dir="$(hookrail_state_dir)"
  session_id="unknown-session"
  turn_id="session"
  if [[ -n "$input_json" && -s "$input_json" ]] && jq -e 'type == "object"' "$input_json" >/dev/null 2>&1; then
    session_id="$(jq -r '.session_id // "unknown-session"' "$input_json")"
    turn_id="$(jq -r '.turn_id // "session"' "$input_json")"
  fi

  safe_session="$(hookrail_safe_component "$session_id")"
  safe_turn="$(hookrail_safe_component "$turn_id")"
  turn_dir="$state_dir/runs/$safe_session/$safe_turn"
  events_dir="$turn_dir/events"
  lock_file="$turn_dir/.lock"
  mkdir -p "$events_dir"

  (
    flock -x 9
    next_seq=1
    for existing in "$events_dir"/[0-9][0-9][0-9][0-9][0-9][0-9]-*.json; do
      [[ -e "$existing" ]] || continue
      base="${existing##*/}"
      seq_text="${base%%-*}"
      seq_value="$(printf '%s\n' "$seq_text" | sed 's/^0*//')"
      [[ -n "$seq_value" ]] || seq_value=0
      ((seq_value < next_seq)) || next_seq=$((seq_value + 1))
    done
    seq_name="$(printf '%06d' "$next_seq")"
    tmp="$(mktemp "$events_dir/.tmp.$seq_name-hookrail-failure.XXXXXX.json")"
    final="$events_dir/$seq_name-hookrail-failure.json"
    jq -n \
      --arg reason "$reason" \
      --arg timestamp "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
      --arg sessionID "$session_id" \
      --arg turnID "$turn_id" \
      '{
        schema: "hookrail.failure_manifest.v1",
        timestamp: $timestamp,
        sessionID: $sessionID,
        turnID: $turnID,
        reason: $reason
      }' >"$tmp"
    mv "$tmp" "$final"
    printf '%s\n' "$final"
  ) 9>"$lock_file"
}
