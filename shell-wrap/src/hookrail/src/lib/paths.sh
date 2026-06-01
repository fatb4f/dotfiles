# shellcheck shell=bash

hookrail_script_dir() {
  local source

  source="${BASH_SOURCE[0]}"
  while [[ -L "$source" ]]; do
    local dir target
    dir="$(cd -P -- "$(dirname -- "$source")" >/dev/null 2>&1 && pwd)"
    target="$(readlink "$source")"
    [[ "$target" == /* ]] || source="$dir/$target"
    [[ "$target" == /* ]] && source="$target"
  done

  cd -P -- "$(dirname -- "$source")" >/dev/null 2>&1 && pwd
}

hookrail_repo_root() {
  local dir

  if [[ -n "${HOOKRAIL_REPO_ROOT:-}" ]]; then
    printf '%s\n' "$HOOKRAIL_REPO_ROOT"
    return
  fi

  dir="$(hookrail_script_dir)"
  if git -C "$dir" rev-parse --show-toplevel >/dev/null 2>&1; then
    git -C "$dir" rev-parse --show-toplevel
    return
  fi

  cd "$dir/../../.." >/dev/null 2>&1 && pwd -P
}

hookrail_cue_dir() {
  if [[ -n "${HOOKRAIL_CUE_DIR:-}" ]]; then
    printf '%s\n' "$HOOKRAIL_CUE_DIR"
    return
  fi

  printf '%s/cue.mods/hookrail\n' "$(hookrail_repo_root)"
}

hookrail_state_dir() {
  if [[ -n "${HOOKRAIL_STATE:-}" ]]; then
    printf '%s\n' "$HOOKRAIL_STATE"
    return
  fi

  if [[ -n "${CODEX_STATE:-}" ]]; then
    printf '%s/hookrail\n' "$CODEX_STATE"
    return
  fi

  printf '%s/.local/state/codex/hookrail\n' "$HOME"
}
