# shellcheck shell=bash
session_osd_require_tool() {
  local tool

  tool="$1"

  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'session osd: missing required command: %s\n' "$tool" >&2
    return 127
  fi
}

session_osd_volume_percent() {
  local output volume

  session_osd_require_tool wpctl || return $?

  output="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)" || return $?

  if [[ "$output" == *MUTED* ]]; then
    printf '%s\n' "muted"
    return 0
  fi

  volume="$(
    awk '
      match($0, /[0-9]+([.][0-9]+)?/) {
        print substr($0, RSTART, RLENGTH)
        exit
      }
    ' <<<"$output"
  )"

  if [[ -z "$volume" ]]; then
    printf 'session osd: unable to parse wpctl volume output\n' >&2
    return 1
  fi

  awk -v volume="$volume" 'BEGIN { printf "%d\n", (volume * 100) + 0.5 }'
}

session_osd_brightness_percent() {
  local current max

  session_osd_require_tool brightnessctl || return $?

  current="$(brightnessctl get 2>/dev/null)" || return $?
  max="$(brightnessctl max 2>/dev/null)" || return $?

  if ! [[ "$current" =~ ^[0-9]+$ && "$max" =~ ^[0-9]+$ ]]; then
    printf 'session osd: unable to parse brightnessctl output\n' >&2
    return 1
  fi

  if ((max <= 0)); then
    printf '%s\n' "0"
    return 0
  fi

  printf '%s\n' "$(((current * 100 + max / 2) / max))"
}

session_osd_notify_volume_state() {
  local value

  value="$1"

  if [[ "$value" == muted ]]; then
    notify_osd mute 0
  else
    notify_osd volume "$value"
  fi
}

session_osd_notify_brightness_state() {
  local value

  value="$1"

  notify_osd brightness "$value"
}

session_osd_volume_up() {
  session_osd_require_tool wpctl || return $?

  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ || return $?
  session_osd_notify_volume_state "$(session_osd_volume_percent)"
}

session_osd_volume_down() {
  session_osd_require_tool wpctl || return $?

  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- || return $?
  session_osd_notify_volume_state "$(session_osd_volume_percent)"
}

session_osd_volume_toggle() {
  session_osd_require_tool wpctl || return $?

  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || return $?
  session_osd_notify_volume_state "$(session_osd_volume_percent)"
}

session_osd_brightness_up() {
  session_osd_require_tool brightnessctl || return $?

  brightnessctl set 5%+ || return $?
  session_osd_notify_brightness_state "$(session_osd_brightness_percent)"
}

session_osd_brightness_down() {
  session_osd_require_tool brightnessctl || return $?

  brightnessctl set 5%- || return $?
  session_osd_notify_brightness_state "$(session_osd_brightness_percent)"
}

session_osd_dispatch() {
  local action

  action="${1:-}"

  case "$action" in
  volume-up)
    session_osd_volume_up
    ;;
  volume-down)
    session_osd_volume_down
    ;;
  volume-toggle)
    session_osd_volume_toggle
    ;;
  brightness-up)
    session_osd_brightness_up
    ;;
  brightness-down)
    session_osd_brightness_down
    ;;
  *)
    printf 'session osd: unknown action: %s\n' "$action" >&2
    return 64
    ;;
  esac
}
