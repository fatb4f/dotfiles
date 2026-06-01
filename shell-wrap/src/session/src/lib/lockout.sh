# shellcheck shell=bash

SESSION_LOCKOUT_DIR="${SESSION_LOCKOUT_DIR:-/run/session-lockout}"
SESSION_LOCKOUT_FILE="${SESSION_LOCKOUT_FILE:-$SESSION_LOCKOUT_DIR/until_epoch}"
SESSION_LOCKOUT_MAX_SECONDS="${SESSION_LOCKOUT_MAX_SECONDS:-14400}"

session_lockout_now() {
  date +%s
}

session_lockout_is_epoch() {
  [[ "${1:-}" =~ ^[0-9]+$ ]]
}

session_lockout_set() {
  local until_epoch now max_until tmp

  until_epoch="${1:?until_epoch required}"

  if ! session_lockout_is_epoch "$until_epoch"; then
    printf 'session lockout set: invalid epoch: %s\n' "$until_epoch" >&2
    return 64
  fi

  now="$(session_lockout_now)"
  max_until="$((now + SESSION_LOCKOUT_MAX_SECONDS))"

  if ((until_epoch <= now)); then
    printf 'session lockout set: deadline is not in the future\n' >&2
    return 64
  fi

  if ((until_epoch > max_until)); then
    printf 'session lockout set: deadline too far in future\n' >&2
    return 64
  fi

  install -d -o root -g root -m 0755 "$SESSION_LOCKOUT_DIR" || return $?

  tmp="$(mktemp "$SESSION_LOCKOUT_DIR/.until_epoch.XXXXXX")" || return $?
  printf '%s\n' "$until_epoch" >"$tmp" || {
    rm -f "$tmp"
    return 1
  }

  chown root:root "$tmp" || {
    rm -f "$tmp"
    return 1
  }

  chmod 0444 "$tmp" || {
    rm -f "$tmp"
    return 1
  }

  mv -f "$tmp" "$SESSION_LOCKOUT_FILE"
}

session_lockout_clear() {
  rm -f "$SESSION_LOCKOUT_FILE"
}

session_lockout_check() {
  local until_epoch now

  [[ -r "$SESSION_LOCKOUT_FILE" ]] || return 0

  until_epoch="$(cat "$SESSION_LOCKOUT_FILE" 2>/dev/null || true)"

  if ! session_lockout_is_epoch "$until_epoch"; then
    return 0
  fi

  now="$(session_lockout_now)"

  if ((now < until_epoch)); then
    printf 'session lockout: unlock denied until %s\n' "$until_epoch" >&2
    return 1
  fi

  return 0
}
