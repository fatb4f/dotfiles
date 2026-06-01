#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export TOMAT_LOG="$tmpdir/tomat.log"
  export TOMAT_BIN="$mockbin/tomat"
  export TOMAT_START_ATTEMPTS=2
  export TOMAT_START_DELAY=0
}

write_tomat() {
  local status="$1"

  cat >"$TOMAT_BIN" <<EOF
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "\$*" >>"\$TOMAT_LOG"

case "\${1:-}" in
  status)
    printf '%s\n' '$status'
    ;;
  start)
    ;;
esac
EOF
  chmod +x "$TOMAT_BIN"
}

@test "tomat-start-work starts work when tomat is idle" {
  write_tomat '{"class":"idle"}'

  run "$BATS_TEST_DIRNAME/../src/session/session" tomat-start-work

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_LOG")" = $'status\nstart' ]
}

@test "tomat-start-work leaves active cycle alone" {
  write_tomat '{"class":"work"}'

  run "$BATS_TEST_DIRNAME/../src/session/session" tomat-start-work

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_LOG")" = "status" ]
}

@test "tomat-start-work waits through stale non-json status before starting idle work" {
  cat >"$TOMAT_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$TOMAT_LOG"

case "${1:-}" in
  status)
    count_file="${TOMAT_LOG}.count"
    count=0
    if [[ -e "$count_file" ]]; then
      count="$(cat "$count_file")"
    fi
    count=$((count + 1))
    printf '%s\n' "$count" >"$count_file"
    if [[ "$count" -eq 1 ]]; then
      printf '%s\n' 'Status: Not running (stale PID file)'
    else
      printf '%s\n' '{"class":"idle"}'
    fi
    ;;
  start)
    ;;
esac
EOF
  chmod +x "$TOMAT_BIN"

  run "$BATS_TEST_DIRNAME/../src/session/session" tomat-start-work

  [ "$status" -eq 0 ]
  [ "$(cat "$TOMAT_LOG")" = $'status\nstatus\nstart' ]
}

@test "tomat-start-work fails open when tomat is missing" {
  export TOMAT_BIN="$tmpdir/missing-tomat"

  run "$BATS_TEST_DIRNAME/../src/session/session" tomat-start-work

  [ "$status" -eq 0 ]
  [ ! -e "$TOMAT_LOG" ]
}
