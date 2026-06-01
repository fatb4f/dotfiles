#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export SYSTEMD_RUN_BIN=systemd-run
  export SESSION_AUTO_START_LOG="$tmpdir/session-auto-start.log"

  cat >"$mockbin/systemd-run" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$SESSION_AUTO_START_LOG"

if [[ "$*" == *"PartOf=graphical-session.target"* ]]; then
  exit 1
fi
EOF
  chmod +x "$mockbin/systemd-run"
}

@test "auto-start uses a fixed transient unit and degrades when PartOf is rejected" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" auto-start

  [ "$status" -eq 0 ]
  [ "$(wc -l <"$SESSION_AUTO_START_LOG")" -eq 2 ]
  [ "$(sed -n '1p' "$SESSION_AUTO_START_LOG")" = "--user --unit=tomat-session-auto-start --property=Type=oneshot --property=RemainAfterExit=yes --property=PartOf=graphical-session.target /home/_404/.local/bin/session tomat-start-work" ]
  [ "$(sed -n '2p' "$SESSION_AUTO_START_LOG")" = "--user --unit=tomat-session-auto-start --property=Type=oneshot --property=RemainAfterExit=yes /home/_404/.local/bin/session tomat-start-work" ]
}

@test "session-auto-start remains a compatibility alias for auto-start" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" session-auto-start

  [ "$status" -eq 0 ]
  [ "$(wc -l <"$SESSION_AUTO_START_LOG")" -eq 2 ]
  [ "$(sed -n '1p' "$SESSION_AUTO_START_LOG")" = "--user --unit=tomat-session-auto-start --property=Type=oneshot --property=RemainAfterExit=yes --property=PartOf=graphical-session.target /home/_404/.local/bin/session tomat-start-work" ]
  [ "$(sed -n '2p' "$SESSION_AUTO_START_LOG")" = "--user --unit=tomat-session-auto-start --property=Type=oneshot --property=RemainAfterExit=yes /home/_404/.local/bin/session tomat-start-work" ]
}
