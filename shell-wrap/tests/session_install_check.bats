#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export SESSION_LOCKOUT_INSTALL_BIN="$tmpdir/usr-local-bin-session"
  export SESSION_LOCKOUT_RUN_DIR="$tmpdir/run-session-lockout"
  export SESSION_LOCKOUT_SUDOERS_FILE="$tmpdir/sudoers-session-lockout"
  export SESSION_LOCKOUT_PAM_FILE="$tmpdir/pam-hyprlock"
  export VISUDO_BIN="$mockbin/visudo"

  checker="$BATS_TEST_DIRNAME/../src/session/system/check-session-lockout-install"

  cat >"$mockbin/stat" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "-c" ]]; then
  /usr/bin/stat "$@"
  exit $?
fi

case "${3:-}" in
  "$SESSION_LOCKOUT_INSTALL_BIN")
    printf '%s\n' "${SESSION_LOCKOUT_TEST_BIN_META:-root:root 755}"
    ;;
  "$SESSION_LOCKOUT_RUN_DIR")
    printf '%s\n' "${SESSION_LOCKOUT_TEST_RUN_META:-root:root 755}"
    ;;
  *)
    /usr/bin/stat "$@"
    ;;
esac
EOF
  chmod +x "$mockbin/stat"

  cat >"$VISUDO_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit "${SESSION_LOCKOUT_TEST_VISUDO_STATUS:-0}"
EOF
  chmod +x "$VISUDO_BIN"
}

write_session_bin() {
  local check_status="${1:-0}"

  cat >"$SESSION_LOCKOUT_INSTALL_BIN" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [[ "\${1:-}" = "lockout" && "\${2:-}" = "check" ]]; then
  exit "$check_status"
fi

exit 64
EOF
  chmod +x "$SESSION_LOCKOUT_INSTALL_BIN"
}

@test "install checker reports ready installed state" {
  write_session_bin 0
  mkdir -p "$SESSION_LOCKOUT_RUN_DIR"
  printf '%s\n' 'Cmnd_Alias SESSION_LOCKOUT_SET = /usr/local/bin/session lockout set *' >"$SESSION_LOCKOUT_SUDOERS_FILE"
  printf '%s\n' 'auth requisite pam_exec.so quiet /usr/local/bin/session lockout check' >"$SESSION_LOCKOUT_PAM_FILE"

  run "$checker"

  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS session-bin exists"* ]]
  [[ "$output" == *"PASS session-bin ownership mode=root:root 755"* ]]
  [[ "$output" == *"PASS session-bin lockout-check"* ]]
  [[ "$output" == *"PASS run-dir ownership mode=root:root 755"* ]]
  [[ "$output" == *"PASS sudoers visudo-check"* ]]
  [[ "$output" == *"PASS pam lockout-line"* ]]
}

@test "install checker skips optional integration files when absent" {
  write_session_bin 0

  run "$checker"

  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP run-dir absent"* ]]
  [[ "$output" == *"SKIP sudoers absent"* ]]
  [[ "$output" == *"SKIP pam absent"* ]]
}

@test "install checker reports inaccessible sudoers separately from absent" {
  write_session_bin 0
  private_dir="$tmpdir/private-sudoers.d"
  inaccessible_sudoers_file="$private_dir/session-lockout"
  mkdir -p "$private_dir"
  printf '%s\n' 'Cmnd_Alias SESSION_LOCKOUT_SET = /usr/local/bin/session lockout set *' >"$inaccessible_sudoers_file"
  chmod 000 "$private_dir"

  run env SESSION_LOCKOUT_SUDOERS_FILE="$inaccessible_sudoers_file" "$checker"

  chmod 700 "$private_dir"

  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP sudoers inaccessible path=$inaccessible_sudoers_file run-as-root=true"* ]]
  [[ "$output" != *"SKIP sudoers absent"* ]]
}

@test "install checker fails missing session binary" {
  run "$checker"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL session-bin missing"* ]]
}

@test "install checker fails non-root binary metadata" {
  write_session_bin 0
  export SESSION_LOCKOUT_TEST_BIN_META="_404:_404 755"

  run "$checker"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL session-bin ownership expected=root:root 755 actual=_404:_404 755"* ]]
}

@test "install checker fails active lockout check" {
  write_session_bin 1

  run "$checker"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL session-bin lockout-check"* ]]
}

@test "install checker fails invalid sudoers and missing PAM line" {
  write_session_bin 0
  printf '%s\n' 'bad sudoers' >"$SESSION_LOCKOUT_SUDOERS_FILE"
  printf '%s\n' 'auth include system-auth' >"$SESSION_LOCKOUT_PAM_FILE"
  export SESSION_LOCKOUT_TEST_VISUDO_STATUS=1

  run "$checker"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL sudoers visudo-check"* ]]
  [[ "$output" == *"FAIL pam lockout-line missing"* ]]
}
