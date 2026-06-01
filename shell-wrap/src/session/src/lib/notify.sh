# shellcheck shell=bash
notify_osd() {
  local kind value body title icon key category

  kind="${1:?kind required}"
  value="${2:?value required}"
  body="${3:-}"

  case "$kind" in
  volume)
    title="Volume"
    icon="audio-volume-high-symbolic"
    key="volume"
    category="audio"
    if [[ -z "$body" ]]; then
      body="${value}%"
    fi
    ;;
  brightness)
    title="Brightness"
    icon="display-brightness-symbolic"
    key="brightness"
    category="brightness"
    if [[ -z "$body" ]]; then
      body="${value}%"
    fi
    ;;
  mute)
    title="Volume"
    icon="audio-volume-muted-symbolic"
    key="volume"
    category="audio"
    value=0
    if [[ -z "$body" ]]; then
      body="Muted"
    fi
    ;;
  *)
    printf 'notify_osd: unknown kind: %s\n' "$kind" >&2
    return 64
    ;;
  esac

  if ! command -v notify-send >/dev/null 2>&1; then
    printf 'notify_osd: missing required command: %s\n' "notify-send" >&2
    return 127
  fi

  notify-send \
    --app-name="System" \
    --urgency=low \
    --expire-time=1200 \
    --category="$category" \
    --icon="$icon" \
    --hint=string:x-canonical-private-synchronous:"$key" \
    --hint=int:value:"$value" \
    "$title" \
    "$body"
}
