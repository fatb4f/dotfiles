#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export SESSION_LOCKOUT_DIR="$tmpdir/lockout"
  export SESSION_LOCKOUT_FILE="$SESSION_LOCKOUT_DIR/until_epoch"
  export SESSION_LOCKOUT_MAX_SECONDS=4000

  cat >"$mockbin/date" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" = "+%s" ]]; then
  printf '%s\n' "${SESSION_LOCKOUT_TEST_NOW:-1000}"
  exit 0
fi

/usr/bin/date "$@"
EOF
  chmod +x "$mockbin/date"

  cat >"$mockbin/install" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

mode=""
dir=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -d)
      shift
      ;;
    -o|-g|-m)
      [[ "$1" = "-m" ]] && mode="$2"
      shift 2
      ;;
    *)
      dir="$1"
      shift
      ;;
  esac
done

mkdir -p "$dir"
[[ -n "$mode" ]] && chmod "$mode" "$dir"
EOF
  chmod +x "$mockbin/install"

  cat >"$mockbin/chown" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF
  chmod +x "$mockbin/chown"
}

@test "lockout check allows unlock when no deadline exists" {
  run "$BATS_TEST_DIRNAME/../src/session/session" lockout check

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lockout set rejects invalid epochs" {
  run "$BATS_TEST_DIRNAME/../src/session/session" lockout set nope

  [ "$status" -eq 64 ]
  [[ "$output" == *"invalid epoch"* ]]
  [ ! -e "$SESSION_LOCKOUT_FILE" ]
}

@test "lockout set rejects past deadlines" {
  run "$BATS_TEST_DIRNAME/../src/session/session" lockout set 1000

  [ "$status" -eq 64 ]
  [[ "$output" == *"deadline is not in the future"* ]]
  [ ! -e "$SESSION_LOCKOUT_FILE" ]
}

@test "lockout set rejects deadlines beyond the guardrail" {
  run "$BATS_TEST_DIRNAME/../src/session/session" lockout set 5001

  [ "$status" -eq 64 ]
  [[ "$output" == *"deadline too far in future"* ]]
  [ ! -e "$SESSION_LOCKOUT_FILE" ]
}

@test "lockout set writes the deadline atomically" {
  run "$BATS_TEST_DIRNAME/../src/session/session" lockout set 1300

  [ "$status" -eq 0 ]
  [ "$(cat "$SESSION_LOCKOUT_FILE")" = "1300" ]
  [ "$(stat -c '%a' "$SESSION_LOCKOUT_FILE")" = "444" ]
}

@test "lockout check denies unlock before the deadline" {
  mkdir -p "$SESSION_LOCKOUT_DIR"
  printf '%s\n' 1300 >"$SESSION_LOCKOUT_FILE"

  run "$BATS_TEST_DIRNAME/../src/session/session" lockout check

  [ "$status" -eq 1 ]
  [[ "$output" == *"unlock denied until 1300"* ]]
}

@test "lockout check propagates denial status to the shell" {
  mkdir -p "$SESSION_LOCKOUT_DIR"
  printf '%s\n' 1300 >"$SESSION_LOCKOUT_FILE"

  set +e
  "$BATS_TEST_DIRNAME/../src/session/session" lockout check >/dev/null 2>&1
  actual_status="$?"
  set -e

  [ "$actual_status" -eq 1 ]
}

@test "lockout check allows unlock at or after the deadline" {
  mkdir -p "$SESSION_LOCKOUT_DIR"
  printf '%s\n' 1300 >"$SESSION_LOCKOUT_FILE"
  export SESSION_LOCKOUT_TEST_NOW=1300

  run "$BATS_TEST_DIRNAME/../src/session/session" lockout check

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lockout check fails open for malformed state" {
  mkdir -p "$SESSION_LOCKOUT_DIR"
  printf '%s\n' nope >"$SESSION_LOCKOUT_FILE"

  run "$BATS_TEST_DIRNAME/../src/session/session" lockout check

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lockout clear removes the deadline" {
  mkdir -p "$SESSION_LOCKOUT_DIR"
  printf '%s\n' 1300 >"$SESSION_LOCKOUT_FILE"

  run "$BATS_TEST_DIRNAME/../src/session/session" lockout clear

  [ "$status" -eq 0 ]
  [ ! -e "$SESSION_LOCKOUT_FILE" ]
}
