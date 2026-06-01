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

write_output_json() {
  report_json="$tmpdir/report.json"
  printf '%s\n' "$output" >"$report_json"
}

assert_json_expr() {
  local path expr

  path="$1"
  expr="$2"

  python3 - "$path" "$expr" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
code = sys.argv[2]
data = json.loads(path.read_text())
allowed_builtins = {
    "any": any,
    "isinstance": isinstance,
    "len": len,
    "list": list,
}
scope = {"data": data}
if "\n" in code:
    exec(code, {"__builtins__": allowed_builtins}, scope)
    result = scope.get("result")
else:
    result = eval(code, {"__builtins__": allowed_builtins}, scope)
if not result:
    raise SystemExit(f"json assertion failed: {code}")
PY
}

@test "verifier reports ready static and live state" {
  run "$verifier"

  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS tomat-break-begin executable"* ]]
  [[ "$output" == *"PASS hypridle on-unlock hook"* ]]
  [[ "$output" == *"PASS tomat break hooks configured"* ]]
  [[ "$output" == *"PASS XDG_RUNTIME_DIR set"* ]]
  [[ "$output" == *"PASS hypridle process running"* ]]
  [[ "$output" == *"PASS tomat status succeeds"* ]]
  [[ "$output" == *"SKIP live lock test detail=disabled"* ]]
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
  [[ "$output" == *"FAIL hypridle on-unlock hook configured"* ]]
}

@test "verifier reports missing tomat hook" {
  perl -0pi -e 's#/usr/local/libexec/tomat-break-end#/tmp/tomat-break-end#' "$SESSION_VERIFY_TOMAT_CONFIG"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat break hooks configured"* ]]
}

@test "verifier reports missing auto advance to-break" {
  perl -0pi -e 's/auto_advance = "to-break"/auto_advance = "all"/' "$SESSION_VERIFY_TOMAT_CONFIG"

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL tomat break hooks configured"* ]]
}

@test "verifier reports missing XDG_RUNTIME_DIR" {
  unset XDG_RUNTIME_DIR

  run "$verifier"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL XDG_RUNTIME_DIR set detail=missing"* ]]
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
  [[ "$output" == *"FAIL tomat status succeeds"* ]]
}

@test "verifier does not run live lock hook by default" {
  hook_log="$tmpdir/hook.log"

  run env SESSION_VERIFY_HOOK_LOG="$hook_log" "$verifier"

  [ "$status" -eq 0 ]
  [ ! -e "$hook_log" ]
  [[ "$output" == *"SKIP live lock test detail=disabled"* ]]
}

@test "verifier runs live lock hook only with explicit flag" {
  hook_log="$tmpdir/hook.log"

  run env SESSION_VERIFY_HOOK_LOG="$hook_log" "$verifier" --live-lock-test

  [ "$status" -eq 0 ]
  [ -s "$hook_log" ]
  [[ "$output" == *"PASS live lock test detail=$libexec_dir/tomat-break-begin"* ]]
}

@test "json mode emits parseable report without human text" {
  run "$verifier" --json

  [ "$status" -eq 0 ]
  [[ "$output" != *"PASS "* ]]
  [[ "$output" != *"INFO manual-checklist"* ]]

  write_output_json
  assert_json_expr "$report_json" 'data["schema"] == "tomat-break-flow.verify.v1"'
  assert_json_expr "$report_json" 'data["ok"] is True'
  assert_json_expr "$report_json" 'isinstance(data["checks"], list) and len(data["checks"]) > 0'
  assert_json_expr "$report_json" 'data["live_lock_test"]["requested"] is False'
  assert_json_expr "$report_json" 'data["live_lock_test"]["status"] == "skipped"'
  assert_json_expr "$report_json" 'data["live_lock_test"]["ok"] is None'
  assert_json_expr "$report_json" 'len(data["manual_checklist"]) > 0'
}

@test "json report includes all verifier checks" {
  run "$verifier" --json

  [ "$status" -eq 0 ]
  write_output_json
  assert_json_expr "$report_json" '''
expected = {
    "libexec.tomat_break_begin.executable",
    "libexec.tomat_break_end.executable",
    "libexec.session_post_unlock.executable",
    "config.hypridle.readable",
    "config.hypridle.on_unlock",
    "config.tomat.readable",
    "config.tomat.hooks",
    "runtime.xdg_runtime_dir",
    "runtime.hypridle.running",
    "runtime.tomat.status",
    "live_lock_test",
}
ids = {check["id"] for check in data["checks"]}
result = expected <= ids
'''
}

@test "json report marks failed check and overall failure" {
  rm -f "$libexec_dir/tomat-break-begin"

  run "$verifier" --json

  [ "$status" -eq 1 ]
  write_output_json
  assert_json_expr "$report_json" 'data["ok"] is False'
  assert_json_expr "$report_json" 'any(check["id"] == "libexec.tomat_break_begin.executable" and check["ok"] is False and check["status"] == "fail" for check in data["checks"])'
}

@test "json report keeps live lock test skipped by default" {
  hook_log="$tmpdir/hook.log"

  run env SESSION_VERIFY_HOOK_LOG="$hook_log" "$verifier" --json

  [ "$status" -eq 0 ]
  [ ! -e "$hook_log" ]
  write_output_json
  assert_json_expr "$report_json" 'data["live_lock_test"] == {"requested": False, "ok": None, "status": "skipped"}'
  assert_json_expr "$report_json" 'any(check["id"] == "live_lock_test" and check["status"] == "skip" for check in data["checks"])'
}

@test "output option writes json report and keeps human stdout" {
  output_report="$tmpdir/output-report.json"

  run "$verifier" --output "$output_report"

  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS tomat-break-begin executable"* ]]
  [[ "$output" == *"INFO manual-checklist start"* ]]
  [ -s "$output_report" ]
  assert_json_expr "$output_report" 'data["ok"] is True'
  assert_json_expr "$output_report" 'data["live_lock_test"]["status"] == "skipped"'
}

@test "json and output together write report and emit json stdout" {
  output_report="$tmpdir/output-report.json"

  run "$verifier" --json --output "$output_report"

  [ "$status" -eq 0 ]
  [[ "$output" != *"PASS "* ]]
  [ -s "$output_report" ]
  write_output_json
  assert_json_expr "$report_json" 'data["ok"] is True'
  assert_json_expr "$output_report" 'data["ok"] is True'
}
