# shellcheck shell=bash
session_lock_transient() {
  local systemd_run_bin

  systemd_run_bin="${SYSTEMD_RUN_BIN:-/usr/bin/systemd-run}"

  "$systemd_run_bin" \
    --user \
    --collect \
    --unit=tomat-break-lock \
    /usr/bin/hyprlock >/dev/null 2>&1 || true
}

session_unlock() {
  :
}

session_auto_start_transient() {
  local systemd_run_bin cli_session_bin

  systemd_run_bin="${SYSTEMD_RUN_BIN:-/usr/bin/systemd-run}"
  cli_session_bin="${CLI_SESSION_BIN:-/home/_404/.local/bin/session}"

  "$systemd_run_bin" \
    --user \
    --unit=tomat-session-auto-start \
    --property=Type=oneshot \
    --property=RemainAfterExit=yes \
    --property=PartOf=graphical-session.target \
    "$cli_session_bin" tomat-start-work >/dev/null 2>&1 && return 0

  "$systemd_run_bin" \
    --user \
    --unit=tomat-session-auto-start \
    --property=Type=oneshot \
    --property=RemainAfterExit=yes \
    "$cli_session_bin" tomat-start-work >/dev/null 2>&1 && return 0

  "$systemd_run_bin" \
    --user \
    --unit=tomat-session-auto-start \
    "$cli_session_bin" tomat-start-work >/dev/null 2>&1 || true
}

session_tomat_start_work() {
  local tomat_bin attempts delay i status

  tomat_bin="${TOMAT_BIN:-/usr/bin/tomat}"
  attempts="${TOMAT_START_ATTEMPTS:-10}"
  delay="${TOMAT_START_DELAY:-0.2}"

  if [[ ! -x "$tomat_bin" ]]; then
    tomat_bin="$(command -v tomat 2>/dev/null || true)"
  fi

  # Fail open. This command runs from systemd ExecStartPost and should not
  # kill tomat.service if the client is missing or daemon readiness is slow.
  [[ -n "$tomat_bin" ]] || return 0

  for ((i = 1; i <= attempts; i++)); do
    status="$("$tomat_bin" status 2>/dev/null || true)"

    case "$status" in
      *'"class":"idle"'* | *'"class": "idle"'*)
        "$tomat_bin" start >/dev/null 2>&1 || true
        return 0
        ;;
      *'"class":'* | *'"class"'*)
        # Daemon is reachable and already owns an active or paused phase.
        return 0
        ;;
      *)
        sleep "$delay"
        ;;
    esac
  done

  return 0
}
