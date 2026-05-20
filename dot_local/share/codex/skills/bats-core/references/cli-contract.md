# Bats CLI contract patterns

## Test intent

Bats is the default choice for executable behavior.

Use it to prove what a user, shell script, or automation sees:

- exit status
- stdout
- stderr
- files created, changed, or removed
- command routing
- argument parsing
- environment-sensitive behavior

## Minimal pattern

```bash
@test "command succeeds" {
  run "$CLI" command --flag value
  assert_success
  assert_output --partial "expected text"
}
```

With plain Bats only:

```bash
@test "command succeeds" {
  run "$CLI" command --flag value
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected text"* ]]
}
```

## Bashly-generated CLI coverage

For a generated Bashly executable, cover the stable user-visible contract first:

```txt
root help
command help
invalid command / invalid flag
missing required arg
success path
failure path
stdout/stderr split
```

Prefer command-facing assertions over implementation details. Do not assert on
private helper function names, generated internal variable names, or incidental
formatting unless the CLI contract explicitly requires it.

## Status first

Always assert status explicitly. Output-only tests are incomplete because a
failing command can still print expected text.

```bash
run "$CLI" --help
assert_success
assert_output --partial "Usage:"
```

## Stderr

Use separate stdout/stderr assertions when a test depends on stream behavior.

```bash
run --separate-stderr "$CLI" bad-input
assert_failure
assert_output ""
assert_stderr --partial "error"
```

If the local Bats version or helpers do not support `--separate-stderr`, redirect
inside the command or use a fixture wrapper and document the fallback.
