# Source or paste into a Bats file when PATH-based executable mocks are needed.

make_path_mock() {
  local name="$1"
  local body="$2"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/$name" <<MOCK
#!/usr/bin/env bash
$body
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/$name"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}
