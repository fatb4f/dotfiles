# shellcheck shell=bash

hookrail_run_hook() {
  local input_json wrapped_json output_json manifest_json persist_json file_stem_json

  hookrail_need jq || return $?
  hookrail_need cue || {
    hookrail_fallback_output
    return 0
  }

  input_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-input.XXXXXX.json")"
  wrapped_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-wrapped.XXXXXX.json")"
  output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-output.XXXXXX.json")"
  manifest_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-manifest.XXXXXX.json")"
  persist_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-persist.XXXXXX.json")"
  file_stem_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-file-stem.XXXXXX.json")"

  trap 'rm -f "$input_json" "$wrapped_json" "$output_json" "$manifest_json" "$persist_json" "$file_stem_json"' RETURN

  if ! hookrail_read_stdin_json "$input_json"; then
    hookrail_fallback_output
    return 0
  fi

  if ! hookrail_wrap_input "$input_json" "$wrapped_json"; then
    hookrail_fallback_output
    return 0
  fi

  if ! hookrail_project_output "$wrapped_json" >"$output_json"; then
    hookrail_fallback_output
    return 0
  fi

  # Export these now so issue 21 proves the adapter asks CUE for projection
  # decisions. Issue 22 uses them for actual persistence.
  hookrail_project_manifest "$wrapped_json" >"$manifest_json" || {
    hookrail_fallback_output
    return 0
  }
  hookrail_project_persist "$wrapped_json" >"$persist_json" || {
    hookrail_fallback_output
    return 0
  }
  hookrail_project_file_stem "$wrapped_json" >"$file_stem_json" || {
    hookrail_fallback_output
    return 0
  }

  hookrail_persist_manifest "$input_json" "$manifest_json" "$persist_json" "$file_stem_json" || {
    hookrail_fallback_output
    return 0
  }

  cat "$output_json"
}
