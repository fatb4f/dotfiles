# shellcheck shell=bash

hookrail_run_doctor() {
  local cue_dir hookrail_bin fixture tmp_root output_json manifest persisted_count
  local clean_repo dirty_repo staged_repo untracked_repo non_git_repo large_prompt trace_file context_artifact closeout_packet

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
  hookrail_need git || return $?
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
  hookrail_doctor_projection_is "$cue_dir/fixtures/session-start-clean.json" '.hookSpecificOutput.additionalContext | contains("hookrail session frame")' "session start projects frame"

  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/hookrail-doctor-state.XXXXXX")"
  output_json="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-adapter-output.XXXXXX.json")"

  jq '.hookInput' "$cue_dir/fixtures/user-prompt-submit.json" |
    HOOKRAIL_STATE="$tmp_root" "$hookrail_bin" hook >"$output_json"
  hookrail_doctor_check "adapter stdout JSON" -- jq -e 'type == "object" and .continue == true' "$output_json"
  hookrail_doctor_check "adapter stdout vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookOutput"' bash "$cue_dir" "$output_json"

  persisted_count="$(find "$tmp_root" -type f -name '*.json' | wc -l | tr -d ' ')"
  [[ "$persisted_count" == "0" ]] || {
    printf 'FAIL small prompt persisted manifest count: got %s expected 0\n' "$persisted_count" >&2
    return 1
  }

  large_prompt="$(printf '%*s' 50001 '' | tr ' ' x)"
  jq --arg prompt "$large_prompt" '.hookInput.prompt = $prompt | .hookInput' "$cue_dir/fixtures/user-prompt-submit.json" |
    HOOKRAIL_STATE="$tmp_root" "$hookrail_bin" hook >"$output_json"
  persisted_count="$(find "$tmp_root/runs" -type f -name '*.json' 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$persisted_count" == "1" ]] || {
    printf 'FAIL large prompt persisted manifest count: got %s expected 1\n' "$persisted_count" >&2
    return 1
  }
  manifest="$(find "$tmp_root/runs" -type f -name '*.json' | sort | sed -n '1p')"
  hookrail_doctor_check "persisted manifest vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#HookManifest"' bash "$cue_dir" "$manifest"
  [[ -z "$(find "$tmp_root" -type f -name '.tmp*' -print)" ]] || {
    printf 'FAIL temporary manifest left behind\n' >&2
    return 1
  }

  clean_repo="$tmp_root/clean-repo"
  dirty_repo="$tmp_root/dirty-repo"
  staged_repo="$tmp_root/staged-repo"
  untracked_repo="$tmp_root/untracked-repo"
  non_git_repo="$tmp_root/non-git"
  hookrail_doctor_init_git_fixture "$clean_repo"
  hookrail_doctor_init_git_fixture "$dirty_repo"
  hookrail_doctor_init_git_fixture "$staged_repo"
  hookrail_doctor_init_git_fixture "$untracked_repo"
  mkdir -p "$non_git_repo"

  printf 'dirty\n' >"$dirty_repo/tracked.txt"
  printf 'staged\n' >"$staged_repo/staged.txt"
  git -C "$staged_repo" add staged.txt
  for n in 1 2 3 4 5; do
    printf 'u%s\n' "$n" >"$untracked_repo/untracked-$n.txt"
  done

  hookrail_doctor_git_facts_is "$clean_repo" '.isRepo == true and .clean == true and .counts.untracked == 0' "git facts clean repo"
  hookrail_doctor_git_facts_is "$dirty_repo" '.isRepo == true and .clean == false and .counts.unstaged == 1' "git facts dirty repo"
  hookrail_doctor_git_facts_is "$staged_repo" '.counts.staged == 1 and .counts.unstaged == 0' "git facts staged repo"
  hookrail_doctor_git_facts_is "$untracked_repo" '.counts.untracked == 5 and (.changedSample | length) == 3 and .truncated == true' "git facts untracked capped"
  hookrail_doctor_git_facts_is "$non_git_repo" '.isRepo == false' "git facts non-git cwd"
  if HOME="$clean_repo" hookrail_git_facts "$clean_repo" >/dev/null 2>&1; then
    printf 'FAIL git facts unsafe HOME root rejected\n' >&2
    return 1
  fi
  printf 'PASS git facts unsafe HOME root rejected\n'

  jq --arg cwd "$clean_repo" '.hookInput.cwd = $cwd | .hookInput' "$cue_dir/fixtures/session-start-clean.json" |
    HOOKRAIL_STATE="$tmp_root" "$hookrail_bin" hook >"$output_json"
  hookrail_doctor_check "session start injects volatile frame" -- jq -e '.hookSpecificOutput.additionalContext | contains("hookrail session frame")' "$output_json"
  persisted_count="$(find "$tmp_root/runs" -type f -name '*session-start*.json' 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$persisted_count" == "0" ]] || {
    printf 'FAIL session frame persisted manifest count: got %s expected 0\n' "$persisted_count" >&2
    return 1
  }
  trace_file="$(find "$tmp_root/trace" -type f -name '*.jsonl' | sort | sed -n '1p')"
  hookrail_doctor_check "trace records frame proof" -- bash -c 'jq -e "select(.hookEventName == \"SessionStart\" and .frame.generated == true and .persisted == false)" "$1"' bash "$trace_file"
  context_artifact="$(find "$tmp_root/runs" -type f -name 'context-frame-input.json' | sort | sed -n '1p')"
  hookrail_doctor_check "context frame input artifact exists" -- test -n "$context_artifact"
  hookrail_doctor_check "context frame input artifact vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#ContextFrameInput"' bash "$cue_dir" "$context_artifact"
  [[ -z "$(find "$clean_repo" -path "$clean_repo/.git" -prune -o -type f -name '*frame*' -print)" ]] || {
    printf 'FAIL repo contains frame artifact\n' >&2
    return 1
  }
  printf 'PASS no repo-persisted frame artifact\n'

  jq --arg cwd "$dirty_repo" '.hookInput.cwd = $cwd | .hookInput' "$cue_dir/fixtures/dirty-stop.json" |
    HOOKRAIL_STATE="$tmp_root" "$hookrail_bin" hook >"$output_json"
  hookrail_doctor_check "runtime dirty stop blocks" -- jq -e '.decision == "block"' "$output_json"
  closeout_packet="$(find "$tmp_root/runs/sess_stop_dirty/turn_stop_dirty" -type f -name 'closeout-packet.json' | sort | sed -n '1p')"
  hookrail_doctor_check "closeout packet artifact exists" -- test -n "$closeout_packet"
  hookrail_doctor_check "closeout packet artifact vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#CloseoutPacket"' bash "$cue_dir" "$closeout_packet"
  hookrail_doctor_check "closeout packet includes stop input facts" -- jq -e '.git.dirty == true and (.git.changedFileSample | length) == 1 and .stopDecisionInput.willBlock == true and (.validation.statuses | length) >= 2' "$closeout_packet"

  jq --arg cwd "$clean_repo" '.hookInput.cwd = $cwd | .hookInput' "$cue_dir/fixtures/session-start-clean.json" |
    HOOKRAIL_STATE="$tmp_root" HOOKRAIL_GIT_FACTS_HELPER="$tmp_root/missing-helper" "$hookrail_bin" hook >"$output_json" 2>/dev/null
  hookrail_doctor_check "missing git helper falls back safely" -- jq -e '.continue == true and .suppressOutput == true' "$output_json"
  manifest="$(find "$tmp_root/runs" -type f -name '*hookrail-failure.json' | sort | sed -n '1p')"
  hookrail_doctor_check "helper failure manifest vets" -- bash -c 'cd "$1" && cue vet -c=false . "$2" -d "#FailureManifest"' bash "$cue_dir" "$manifest"

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

hookrail_doctor_init_git_fixture() {
  local path

  path="${1:?fixture path required}"
  mkdir -p "$path"
  git -C "$path" init -q
  git -C "$path" config user.name "Hookrail Doctor"
  git -C "$path" config user.email "hookrail-doctor@example.invalid"
  printf 'base\n' >"$path/tracked.txt"
  git -C "$path" add tracked.txt
  git -C "$path" commit -q -m "test: initial fixture"
}

hookrail_doctor_git_facts_is() {
  local repo jq_expr label facts

  repo="${1:?repo required}"
  jq_expr="${2:?jq expression required}"
  label="${3:?label required}"
  facts="$(mktemp "${TMPDIR:-/tmp}/hookrail-doctor-git-facts.XXXXXX.json")"
  HOOKRAIL_GIT_SAMPLE_LIMIT=3 hookrail_git_facts "$repo" >"$facts"
  hookrail_doctor_check "$label" -- jq -e "$jq_expr" "$facts"
  rm -f "$facts"
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
