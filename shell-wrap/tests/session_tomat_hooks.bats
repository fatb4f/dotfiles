#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export SUDO_BIN="$mockbin/sudo"
  export LOGINCTL_BIN="$mockbin/loginctl"
  export SESSION_BIN="/usr/local/bin/session"
  export TOMAT_BIN="$mockbin/tomat"
  export TOMAT_HOOK_LOG="$tmpdir/tomat-hook.log"
  export SESSION_BREAK_DIR="$tmpdir/session-break"

  hook_dir="$BATS_TEST_DIRNAME/../src/session/system/tomat"

  cat >"$mockbin/date" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" = "+%s" ]]; then
  printf '%s\n' 1000
  exit 0
fi

/usr/bin/date "$@"
EOF
  chmod +x "$mockbin/date"

  cat >"$SUDO_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'sudo %s\n' "$*" >>"$TOMAT_HOOK_LOG"
EOF
  chmod +x "$SUDO_BIN"

  cat >"$LOGINCTL_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'loginctl %s\n' "$*" >>"$TOMAT_HOOK_LOG"
EOF
  chmod +x "$LOGINCTL_BIN"

  cat >"$TOMAT_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'tomat %s\n' "$*" >>"$TOMAT_HOOK_LOG"
EOF
  chmod +x "$TOMAT_BIN"
}

write_session_mock() {
  local consume_status="${1:-0}"

  export SESSION_BIN="$mockbin/session"

  cat >"$SESSION_BIN" <<EOF
#!/usr/bin/env bash
set -euo pipefail

printf 'session %s\n' "\$*" >>"\$TOMAT_HOOK_LOG"

case "\${1:-} \${2:-}" in
  "break consume-resume-pending")
    exit "$consume_status"
    ;;
esac
EOF
  chmod +x "$SESSION_BIN"
}

@test "tomat-break-begin computes deadline from TOMAT_REMAINING_SECONDS and locks" {
  export TOMAT_REMAINING_SECONDS=300

  run "$hook_dir/tomat-break-begin"

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_HOOK_LOG")" = $'sudo /usr/local/bin/session lockout set 1300\nloginctl lock-session' ]
}

@test "tomat-break-begin requires TOMAT_REMAINING_SECONDS" {
  run "$hook_dir/tomat-break-begin"

  [ "$status" -ne 0 ]
}

@test "tomat-break-end clears lockout and marks resume pending" {
  write_session_mock 0

  run "$hook_dir/tomat-break-end"

  [ "$status" -eq 0 ]
  [[ "$(cat "$TOMAT_HOOK_LOG")" == sudo\ /tmp/* ]]
  [[ "$(cat "$TOMAT_HOOK_LOG")" == *"lockout clear"* ]]
  [[ "$(cat "$TOMAT_HOOK_LOG")" == *"break mark-resume-pending"* ]]
}

@test "session-post-unlock resumes tomat only when marker consumed" {
  write_session_mock 0

  run "$hook_dir/session-post-unlock"

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_HOOK_LOG")" = $'session break consume-resume-pending\ntomat resume' ]
}

@test "session-post-unlock does not resume tomat without pending marker" {
  write_session_mock 1

  run "$hook_dir/session-post-unlock"

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_HOOK_LOG")" = "session break consume-resume-pending" ]
}
