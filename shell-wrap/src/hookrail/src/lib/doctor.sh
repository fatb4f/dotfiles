# shellcheck shell=bash

hookrail_run_doctor() {
  local cue_dir fixture

  cue_dir="$(hookrail_cue_dir)"
  [[ -d "$cue_dir" ]] || {
    printf 'FAIL missing CUE module: %s\n' "$cue_dir" >&2
    return 1
  }

  hookrail_need cue || return $?
  hookrail_need jq || return $?

  (cd "$cue_dir" && cue vet -c=false .) || return $?

  for fixture in "$cue_dir"/fixtures/*.json; do
    [[ -f "$fixture" ]] || continue
    (cd "$cue_dir" && cue export . "$fixture" -e '#HookProjection.output' --out json) | jq -e 'type == "object"' >/dev/null
    (cd "$cue_dir" && cue export . "$fixture" -e '#HookProjection.manifest' --out json) | jq -e '.schema == "hookrail.manifest.v1"' >/dev/null
  done

  printf 'hookrail doctor: ok\n'
}
