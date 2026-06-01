# shellcheck shell=bash

hookrail_run_hook() {
  local input_json normalized_json wrapped_json output_json manifest_json persist_json file_stem_json manifest_path

  hookrail_need jq || return $?
  hookrail_need cue || {
    hookrail_fallback_output
    return 0
  }

  input_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-input.XXXXXX.json")"
  normalized_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-normalized.XXXXXX.json")"
  wrapped_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-wrapped.XXXXXX.json")"
  output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-output.XXXXXX.json")"
  manifest_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-manifest.XXXXXX.json")"
  persist_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-persist.XXXXXX.json")"
  file_stem_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-hook-file-stem.XXXXXX.json")"

  trap 'rm -f "$input_json" "$normalized_json" "$wrapped_json" "$output_json" "$manifest_json" "$persist_json" "$file_stem_json"' RETURN

  if ! hookrail_read_stdin_json "$input_json"; then
    hookrail_persist_failure_manifest "malformed-input" "$input_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  fi

  if ! hookrail_enrich_input "$input_json" "$normalized_json"; then
    hookrail_persist_failure_manifest "runtime-facts-failure" "$input_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  fi

  if ! hookrail_wrap_input "$normalized_json" "$wrapped_json"; then
    hookrail_persist_failure_manifest "normalization-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  fi

  if ! hookrail_project_output "$wrapped_json" >"$output_json"; then
    hookrail_persist_failure_manifest "projection-output-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  fi

  # Export these now so issue 21 proves the adapter asks CUE for projection
  # decisions. Issue 22 uses them for actual persistence.
  hookrail_project_manifest "$wrapped_json" >"$manifest_json" || {
    hookrail_persist_failure_manifest "projection-manifest-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  }
  hookrail_project_persist "$wrapped_json" >"$persist_json" || {
    hookrail_persist_failure_manifest "projection-persist-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  }
  hookrail_project_file_stem "$wrapped_json" >"$file_stem_json" || {
    hookrail_persist_failure_manifest "projection-file-stem-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  }

  manifest_path="$(hookrail_persist_manifest "$normalized_json" "$manifest_json" "$persist_json" "$file_stem_json")" || {
    hookrail_persist_failure_manifest "manifest-persist-failure" "$normalized_json" >/dev/null 2>&1 || true
    hookrail_fallback_output "$input_json"
    return 0
  }

  hookrail_try_persist_runtime_artifacts "$normalized_json" "$output_json"
  hookrail_try_append_trace "$normalized_json" "$output_json" "$manifest_path"
  cat "$output_json"
}
