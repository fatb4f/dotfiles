#!/usr/bin/env bats

# Starter template for Bats tests around a generated Bashly CLI.
# Copy into tests/ or test/ and set CLI to the generated executable.

setup() {
  CLI="${CLI:-./bin/example}"
}

@test "root help exits successfully" {
  run "$CLI" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "invalid flag exits non-zero" {
  run "$CLI" --definitely-invalid
  [ "$status" -ne 0 ]
}

@test "missing required input exits non-zero" {
  run "$CLI" run
  [ "$status" -ne 0 ]
}
