#!/usr/bin/env bats

# Starter template for generated Bashly CLI contract tests.
# Copy into a project test directory and set CLI under setup.

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
