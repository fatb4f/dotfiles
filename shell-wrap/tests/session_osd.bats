#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  tmpdir="$(mktemp -d)"
  mockbin="$tmpdir/mockbin"
  mkdir -p "$mockbin"

  export PATH="$mockbin:$PATH"
  export WPCTL_STATE="$tmpdir/wpctl.state"
  export BRIGHTNESS_STATE="$tmpdir/brightness.state"
  export NOTIFY_LOG="$tmpdir/notify.log"

  printf '%s\n' "volume=0.30" "muted=0" >"$WPCTL_STATE"
  printf '%s\n' "current=40" "max=100" >"$BRIGHTNESS_STATE"

  cat >"$mockbin/wpctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state="$WPCTL_STATE"
cmd="${1:-}"
sink="${2:-}"
arg="${3:-}"

volume="$(sed -n 's/^volume=//p' "$state")"
muted="$(sed -n 's/^muted=//p' "$state")"

case "$cmd $sink $arg" in
  "get-volume @DEFAULT_AUDIO_SINK@ ")
    if [[ "$muted" == 1 ]]; then
      printf 'Volume: %s [MUTED]\n' "$volume"
    else
      printf 'Volume: %s\n' "$volume"
    fi
    ;;
  "set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    volume="$(awk -v value="$volume" 'BEGIN { printf "%.2f\n", value + 0.05 }')"
    printf 'volume=%s\nmuted=%s\n' "$volume" "$muted" >"$state"
    ;;
  "set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    volume="$(awk -v value="$volume" 'BEGIN { printf "%.2f\n", value - 0.05 }')"
    printf 'volume=%s\nmuted=%s\n' "$volume" "$muted" >"$state"
    ;;
  "set-mute @DEFAULT_AUDIO_SINK@ toggle")
    if [[ "$muted" == 1 ]]; then
      muted=0
    else
      muted=1
    fi
    printf 'volume=%s\nmuted=%s\n' "$volume" "$muted" >"$state"
    ;;
  *)
    printf 'unexpected wpctl args: %s %s %s\n' "$cmd" "$sink" "$arg" >&2
    exit 1
    ;;
esac
EOF
  chmod +x "$mockbin/wpctl"

  cat >"$mockbin/brightnessctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state="$BRIGHTNESS_STATE"
cmd="${1:-}"
arg="${2:-}"

current="$(sed -n 's/^current=//p' "$state")"
max="$(sed -n 's/^max=//p' "$state")"

case "$cmd $arg" in
  "get ")
    printf '%s\n' "$current"
    ;;
  "max ")
    printf '%s\n' "$max"
    ;;
  "set 5%+")
    current=$((current + max / 20))
    printf 'current=%s\nmax=%s\n' "$current" "$max" >"$state"
    ;;
  "set 5%-")
    current=$((current - max / 20))
    printf 'current=%s\nmax=%s\n' "$current" "$max" >"$state"
    ;;
  *)
    printf 'unexpected brightnessctl args: %s %s\n' "$cmd" "$arg" >&2
    exit 1
    ;;
esac
EOF
  chmod +x "$mockbin/brightnessctl"

  cat >"$mockbin/notify-send" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

{
  printf '%s\n' "$@"
  printf -- '--\n'
} >>"$NOTIFY_LOG"
EOF
  chmod +x "$mockbin/notify-send"
}

assert_notify_call() {
  local expected_hint expected_category expected_icon expected_title expected_body

  expected_hint="$1"
  expected_category="$2"
  expected_icon="$3"
  expected_title="$4"
  expected_body="$5"

  [ "$(grep -c '^--$' "$NOTIFY_LOG")" -eq 1 ]
  grep -Fxq -- "--app-name=System" "$NOTIFY_LOG"
  grep -Fxq -- "--urgency=low" "$NOTIFY_LOG"
  grep -Fxq -- "--expire-time=1200" "$NOTIFY_LOG"
  grep -Fxq -- "--category=$expected_category" "$NOTIFY_LOG"
  grep -Fxq -- "$expected_hint" "$NOTIFY_LOG"
  grep -Fxq -- "--icon=$expected_icon" "$NOTIFY_LOG"
  grep -Fxq -- "$expected_title" "$NOTIFY_LOG"
  grep -Fxq -- "$expected_body" "$NOTIFY_LOG"
}

@test "volume-up hydrates final state and notifies" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd volume-up

  [ "$status" -eq 0 ]
  assert_notify_call "--hint=int:value:35" "audio" "audio-volume-high-symbolic" "Volume" "35%"
}

@test "volume-down hydrates final state and notifies" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd volume-down

  [ "$status" -eq 0 ]
  assert_notify_call "--hint=int:value:25" "audio" "audio-volume-high-symbolic" "Volume" "25%"
}

@test "volume-toggle hydrates muted state and notifies" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd volume-toggle

  [ "$status" -eq 0 ]
  assert_notify_call "--hint=int:value:0" "audio" "audio-volume-muted-symbolic" "Volume" "Muted"
}

@test "brightness-up hydrates final state and notifies" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd brightness-up

  [ "$status" -eq 0 ]
  assert_notify_call "--hint=int:value:45" "brightness" "display-brightness-symbolic" "Brightness" "45%"
}

@test "brightness-down hydrates final state and notifies" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd brightness-down

  [ "$status" -eq 0 ]
  assert_notify_call "--hint=int:value:35" "brightness" "display-brightness-symbolic" "Brightness" "35%"
}

@test "unknown osd actions fail clearly" {
  run "$BATS_TEST_DIRNAME/../src/cli.session/session" osd nope

  [ "$status" -ne 0 ]
  [[ "$output" == *"session osd: unknown action: nope"* ]]
}
