#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  export SESSION_BREAK_DIR="$tmpdir/session-break"
  export SESSION_BREAK_PENDING_FILE="$SESSION_BREAK_DIR/pending_resume"
}

@test "mark-resume-pending creates marker" {
  run "$BATS_TEST_DIRNAME/../src/session/session" break mark-resume-pending

  [ "$status" -eq 0 ]
  [ -e "$SESSION_BREAK_PENDING_FILE" ]
}

@test "mark-resume-pending is idempotent" {
  mkdir -p "$SESSION_BREAK_DIR"
  printf '%s\n' pending >"$SESSION_BREAK_PENDING_FILE"

  run "$BATS_TEST_DIRNAME/../src/session/session" break mark-resume-pending

  [ "$status" -eq 0 ]
  [ -e "$SESSION_BREAK_PENDING_FILE" ]
}

@test "consume-resume-pending removes marker and exits success when present" {
  mkdir -p "$SESSION_BREAK_DIR"
  printf '%s\n' pending >"$SESSION_BREAK_PENDING_FILE"

  run "$BATS_TEST_DIRNAME/../src/session/session" break consume-resume-pending

  [ "$status" -eq 0 ]
  [ ! -e "$SESSION_BREAK_PENDING_FILE" ]
}

@test "consume-resume-pending exits nonzero when absent" {
  run "$BATS_TEST_DIRNAME/../src/session/session" break consume-resume-pending

  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "consume-resume-pending absent marker is safe repeatedly" {
  run "$BATS_TEST_DIRNAME/../src/session/session" break consume-resume-pending

  [ "$status" -eq 1 ]

  run "$BATS_TEST_DIRNAME/../src/session/session" break consume-resume-pending

  [ "$status" -eq 1 ]
}
