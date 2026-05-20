# Bats assertions and output

## Preferred helpers

When available, use:

```bash
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'
```

Common assertions:

```bash
assert_success
assert_failure
assert_output "exact output"
assert_output --partial "substring"
assert_line --partial "line substring"
assert_file_exists "$path"
assert_dir_exists "$dir"
```

## Plain Bats fallback

When helpers are not installed, keep assertions explicit:

```bash
[ "$status" -eq 0 ]
[[ "$output" == *"expected"* ]]
[ -f "$path" ]
```

Do not hide many checks behind opaque helper functions unless the repository
already has a clear test helper convention.

## Output normalization

Normalize only when the CLI contract allows it.

Useful cases:

- stripping ANSI color from output that is not contractually color-sensitive
- replacing temp paths with placeholders
- sorting output when order is explicitly irrelevant

Do not normalize away contract failures such as missing newlines, unexpected
stderr, or changed usage text.

## Debugging failed tests

During diagnosis, print structured debug evidence:

```bash
echo "status=$status" >&3
printf 'output=%s\n' "$output" >&3
printf 'stderr=%s\n' "$stderr" >&3
```

Use file descriptor `3` for debug output visible in Bats runs.
