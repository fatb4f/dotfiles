#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  libexec_dir="$tmpdir/libexec"
  mkdir -p "$mockbin" "$libexec_dir"

  export PATH="$mockbin:$PATH"
  export SESSION_VERIFY_LIBEXEC_DIR="$libexec_dir"
  export SESSION_VERIFY_HYPRIDLE_CONF="$tmpdir/hypridle.conf"
  export SESSION_VERIFY_TOMAT_CONFIG="$tmpdir/tomat.toml"
  export SESSION_VERIFY_TOMAT_BIN="$mockbin/tomat"
  export SESSION_VERIFY_PGREP_BIN="$mockbin/pgrep"
  export XDG_RUNTIME_DIR="$tmpdir/runtime"

  verifier="$BATS_TEST_DIRNAME/../scripts/verify-tomat-break-flow"

  write_good_fixtures
}

write_good_fixtures() {
  mkdir -p "$XDG_RUNTIME_DIR"

  for hook in tomat-break-begin tomat-break-end session-post-unlock; do
    cat >"$libexec_dir/$hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$0 $*" >>"${SESSION_VERIFY_HOOK_LOG:-/dev/null}"
EOF
    chmod +x "$libexec_dir/$hook"
  done

  cat >"$SESSION_VERIFY_HYPRIDLE_CONF" <<'EOF'
general {
    on_unlock_cmd = /usr/local/libexec/session-post-unlock
}
EOF

  cat >"$SESSION_VERIFY_TOMAT_CONFIG" <<'EOF'
[timer]
auto_advance = "to-break"

[hooks.on_break_start]
cmd = "/usr/local/libexec/tomat-break-begin"

[hooks.on_long_break_start]
cmd = "/usr/local/libexec/tomat-break-begin"

[hooks.on_break_end]
cmd = "/usr/local/libexec/tomat-break-end"

[hooks.on_long_break_end]
cmd = "/usr/local/libexec/tomat-break-end"
EOF

  cat >"$SESSION_VERIFY_TOMAT_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" = "status" ]]
EOF
  chmod +x "$SESSION_VERIFY_TOMAT_BIN"

  cat >"$SESSION_VERIFY_PGREP_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" = "-x" && "${2:-}" = "hypridle" ]]
EOF
  chmod +x "$SESSION_VERIFY_PGREP_BIN"
}

@test "verifier reports ready static and live state" {
  run "$verifier"

  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS tomat-break-begin executable"* ]]
  [[ "$output" == *"PASS hypridle on-unlock hook"* ]]
  [[ "$output" == *"PASS tomat config hooks"* ]]
  [[ "$output" == *"PASS xdg-runtime-dir set"* ]]
  [[ "$output" == *"PASS hypridle process running"* ]]
  [[ "$output" == *"PASS tomat status"* ]]
  [[ "$output" == *"SKIP live-lock-test disabled"* ]]
  [[ "$output" == *"INFO manual-checklist start"* ]]
}

@test "verifier reports missing libexec hook" {
  rm -f "$libexec_dir/tomat-break-begin"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat-break-begin missing"* ]]
}

@test "verifier reports missing hypridle unlock command" {
  printf '%s\n' 'general {}' >"$SESSION_VERIFY_HYPRIDLE_CONF"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL hypridle on-unlock hook missing"* ]]
}

@test "verifier reports missing tomat hook" {
  perl -0pi -e 's#/usr/local/libexec/tomat-break-end#/tmp/tomat-break-end#' "$SESSION_VERIFY_TOMAT_CONFIG"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat config hooks"* ]]
}

@test "verifier reports missing auto advance to-break" {
  perl -0pi -e 's/auto_advance = "to-break"/auto_advance = "all"/' "$SESSION_VERIFY_TOMAT_CONFIG"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat config hooks"* ]]
}

@test "verifier reports missing XDG_RUNTIME_DIR" {
  unset XDG_RUNTIME_DIR

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL xdg-runtime-dir missing"* ]]
}

@test "verifier reports tomat daemon status failure" {
  cat >"$SESSION_VERIFY_TOMAT_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 1
EOF
  chmod +x "$SESSION_VERIFY_TOMAT_BIN"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat status"* ]]
}

@test "verifier does not run live lock hook by default" {
  hook_log="$tmpdir/hook.log"

  run env SESSION_VERIFY_HOOK_LOG="$hook_log" "$verifier"

  [ "$status" -eq 0 ]
  [ ! -e "$hook_log" ]
  [[ "$output" == *"SKIP live-lock-test disabled"* ]]
}

@test "verifier runs live lock hook only with explicit flag" {
  hook_log="$tmpdir/hook.log"

  run env SESSION_VERIFY_HOOK_LOG="$hook_log" "$verifier" --live-lock-test

  [ "$status" -eq 0 ]
  [ -s "$hook_log" ]
  [[ "$output" == *"PASS live-lock-test tomat-break-begin"* ]]
}
