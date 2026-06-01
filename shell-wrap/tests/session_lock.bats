#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export SYSTEMD_RUN_BIN=systemd-run
  export SESSION_LOCK_LOG="$tmpdir/session-lock.log"
  export SESSION_LOCK_LOGINCTL_LOG="$tmpdir/loginctl.log"

  cat >"$mockbin/systemd-run" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$SESSION_LOCK_LOG"
exit "${SYSTEMD_RUN_EXIT_CODE:-0}"
EOF
  chmod +x "$mockbin/systemd-run"

  cat >"$mockbin/loginctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$SESSION_LOCK_LOGINCTL_LOG"
exit 99
EOF
  chmod +x "$mockbin/loginctl"
}

@test "lock starts hyprlock through transient systemd-run" {
  export SYSTEMD_RUN_EXIT_CODE=1

  run "$BATS_TEST_DIRNAME/../src/session/session" lock

  [ "$status" -eq 0 ]
  [ "$(cat "$SESSION_LOCK_LOG")" = "--user --collect --unit=tomat-break-lock /usr/bin/hyprlock" ]
  [ ! -e "$SESSION_LOCK_LOGINCTL_LOG" ]
}

@test "session-lock remains a compatibility alias for lock" {
  export SYSTEMD_RUN_EXIT_CODE=1

  run "$BATS_TEST_DIRNAME/../src/session/session" session-lock

  [ "$status" -eq 0 ]
  [ "$(cat "$SESSION_LOCK_LOG")" = "--user --collect --unit=tomat-break-lock /usr/bin/hyprlock" ]
  [ ! -e "$SESSION_LOCK_LOGINCTL_LOG" ]
}
