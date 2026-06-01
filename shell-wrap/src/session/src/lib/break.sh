# shellcheck shell=bash

session_break_runtime_dir() {
  if [[ -n "${SESSION_BREAK_DIR:-}" ]]; then
    printf '%s\n' "$SESSION_BREAK_DIR"
    return
  fi

  if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    printf '%s\n' "$XDG_RUNTIME_DIR/session-break"
    return
  fi

  printf '/run/user/%s/session-break\n' "$(id -u)"
}

session_break_pending_file() {
  if [[ -n "${SESSION_BREAK_PENDING_FILE:-}" ]]; then
    printf '%s\n' "$SESSION_BREAK_PENDING_FILE"
    return
  fi

  printf '%s/pending_resume\n' "$(session_break_runtime_dir)"
}

session_break_mark_resume_pending() {
  local pending_file pending_dir tmp

  pending_file="$(session_break_pending_file)"
  pending_dir="$(dirname -- "$pending_file")"

  mkdir -p "$pending_dir" || return $?

  tmp="$(mktemp "$pending_dir/.pending_resume.XXXXXX")" || return $?
  printf '%s\n' pending >"$tmp" || {
    rm -f "$tmp"
    return 1
  }

  mv -f "$tmp" "$pending_file"
}

session_break_consume_resume_pending() {
  local pending_file

  pending_file="$(session_break_pending_file)"

  [[ -e "$pending_file" ]] || return 1
  rm -f "$pending_file"
}
