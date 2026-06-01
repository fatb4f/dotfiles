# shellcheck shell=bash

hookrail_run_doctor() {
  local cue_dir hookrail_bin fixture tmp_root output_json manifest persisted_count

  cue_dir="$(hookrail_cue_dir)"
  hookrail_bin="${HOOKRAIL_BIN:-$(hookrail_script_dir)/hookrail}"
  [[ -d "$cue_dir" ]] || {
    printf 'FAIL missing CUE module: %s\n' "$cue_dir" >&2
    return 1
  }
  [[ -x "$hookrail_bin" ]] || {
    printf 'FAIL missing hookrail executable: %s\n' "$hookrail_bin" >&2
    return 1
  }

  hookrail_need cue || return $?
  hookrail_need jq || return $?
  hookrail_need grep || return $?
  hookrail_need find || return $?
  hookrail_need mktemp || return $?

  hookrail_doctor_check "cue vet" -- bash -c 'cd "$1" && cue vet -c=false .' bash "$cue_dir"

  for fixture in "$cue_dir"/fixtures/*.json; do
    [[ -f "$fixture" ]] || continue
    output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-output.XXXXXX.json")"
    manifest="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-manifest.XXXXXX.json")"
    hookrail_doctor_check "project output $(basename "$fixture")" -- bash -c 'cd "$1" && cue export . "$2" -e "#HookProjection.output" --out json >"$3"' bash "$cue_dir" "$fixture" "$output_json"
    hookrail_doctor_check "vet output $(basename "$fixture")" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookOutput"' bash "$cue_dir" "$output_json"
    hookrail_doctor_check "project manifest $(basename "$fixture")" -- bash -c 'cd "$1" && cue export . "$2" -e "#HookProjection.manifest" --out json >"$3"' bash "$cue_dir" "$fixture" "$manifest"
    hookrail_doctor_check "vet manifest $(basename "$fixture")" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookManifest"' bash "$cue_dir" "$manifest"
    rm -f "$output_json" "$manifest"
  done

  hookrail_doctor_projection_is "$cue_dir/fixtures/dirty-stop.json" '.decision == "block"' "dirty stop blocks"
  hookrail_doctor_projection_is "$cue_dir/fixtures/clean-stop.json" '.continue == true' "clean stop continues"
  hookrail_doctor_projection_is "$cue_dir/fixtures/dirty-stop-active.json" '.continue == true and (.systemMessage | contains("already active"))' "active stop continues"

  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/hookrail-doctor-state.XXXXXX")"
  output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-adapter-output.XXXXXX.json")"

  jq '.hookInput' "$cue_dir/fixtures/user-prompt-submit.json" |
    HOOKRAIL_STATE="$tmp_root" "$hookrail_bin" hook >"$output_json"
  hookrail_doctor_check "adapter stdout JSON" -- jq -e 'type == "object" and .continue == true' "$output_json"
  hookrail_doctor_check "adapter stdout vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookOutput"' bash "$cue_dir" "$output_json"

  persisted_count="$(find "$tmp_root" -type f -name '*.json' | wc -l | tr -d ' ')"
  [[ "$persisted_count" == "1" ]] || {
    printf 'FAIL persisted manifest count: got %s expected 1\n' "$persisted_count" >&2
    return 1
  }
  manifest="$(find "$tmp_root" -type f -name '*.json' | sort | sed -n '1p')"
  hookrail_doctor_check "persisted manifest vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookManifest"' bash "$cue_dir" "$manifest"
  [[ -z "$(find "$tmp_root" -type f -name '.tmp*' -print)" ]] || {
    printf 'FAIL temporary manifest left behind\n' >&2
    return 1
  }

  jq '.hookInput' "$cue_dir/fixtures/user-prompt-submit.json" |
    HOOKRAIL_CUE_DIR="$tmp_root/missing" "$hookrail_bin" hook >"$output_json" 2>/dev/null
  hookrail_doctor_check "fallback stdout JSON" -- jq -e '.continue == true and .suppressOutput == true' "$output_json"

  hookrail_doctor_check "adapter invokes cue" -- grep -F 'cue export' "$hookrail_bin"
  if grep -F 'Before final summary' "$(hookrail_script_dir)/src/lib/hook.sh" "$(hookrail_script_dir)/src/lib/cue.sh" "$(hookrail_script_dir)/src/lib/persist.sh" >/dev/null; then
    printf 'FAIL adapter embeds closeout decision text instead of delegating to CUE\n' >&2
    return 1
  fi

  rm -rf "$tmp_root"
  rm -f "$output_json"

  printf 'hookrail doctor: ok\n'
}

hookrail_doctor_check() {
  local label

  label="${1:?label required}"
  shift
  [[ "${1:-}" == "--" ]] && shift

  if "$@" >/dev/null; then
    printf 'PASS %s\n' "$label"
    return 0
  fi

  printf 'FAIL %s\n' "$label" >&2
  return 1
}

hookrail_doctor_projection_is() {
  local fixture jq_expr label output_json cue_dir

  fixture="${1:?fixture required}"
  jq_expr="${2:?jq expression required}"
  label="${3:?label required}"
  cue_dir="$(hookrail_cue_dir)"
  output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-projection.XXXXXX.json")"

  (cd "$cue_dir" && cue export . "$fixture" -e '#HookProjection.output' --out json >"$output_json")
  hookrail_doctor_check "$label" -- jq -e "$jq_expr" "$output_json"
  rm -f "$output_json"
}
