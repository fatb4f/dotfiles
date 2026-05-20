# Bats fixtures and mocks

## Temporary state

Use Bats-managed temporary directories.

```bash
setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}
```

Prefer `$BATS_TEST_TMPDIR` over `$TMPDIR` for per-test isolation.

## Fixture layout

Keep fixtures close to tests when they are test-specific:

```txt
tests/
  fixtures/
    input.txt
  cli.bats
```

Use `$BATS_TEST_DIRNAME` to resolve fixture paths:

```bash
fixture="$BATS_TEST_DIRNAME/fixtures/input.txt"
```

## PATH command mocks

For executable integration tests, mock external commands by prepending a bin
directory to PATH.

```bash
setup() {
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  mkdir -p "$BATS_TEST_TMPDIR/bin"

  cat > "$BATS_TEST_TMPDIR/bin/git" <<'MOCK'
#!/usr/bin/env bash
printf 'mock git %s\n' "$*"
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/git"
}
```

This keeps the test black-box while avoiding real network, package manager,
Git, or system mutation.

## Unsafe dependencies

Do not let normal tests hit:

- real package managers
- real network APIs
- user home directories
- system service managers
- destructive filesystem paths

Put those behind explicit integration tags or repository-specific smoke runners.
