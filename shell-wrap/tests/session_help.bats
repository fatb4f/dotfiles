#!/usr/bin/env bats

# shellcheck shell=bats

@test "session help exposes the public surface and visible compatibility aliases" {
  run "$BATS_TEST_DIRNAME/../src/session/session" --help

  [ "$status" -eq 0 ]
  [[ "$output" == *"Session lock, startup, and OSD manager"* ]]
  [[ "$output" == *"  lock"* ]]
  [[ "$output" == *"  unlock"* ]]
  [[ "$output" == *"  lockout"* ]]
  [[ "$output" == *"  auto-start"* ]]
  [[ "$output" == *"  osd"* ]]
  [[ "$output" == *"session-lock"* ]]
  [[ "$output" == *"Deprecated alias for lock"* ]]
  [[ "$output" == *"session-auto-start"* ]]
  [[ "$output" == *"Deprecated alias for auto-start"* ]]
  [[ "$output" == *"tomat-start-work"* ]]
  [[ "$output" == *"Internal helper: start Tomat work if daemon is idle"* ]]
  [[ "$output" != *"locker"* ]]
}
