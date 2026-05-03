# shellcheck shell=bash

: "${HOME:?HOME is required}"
: "${XDG_CONFIG_HOME:?XDG_CONFIG_HOME must be set before 40-apps.sh}"
: "${XDG_CACHE_HOME:?XDG_CACHE_HOME must be set before 40-apps.sh}"
: "${XDG_DATA_HOME:?XDG_DATA_HOME must be set before 40-apps.sh}"
: "${XDG_STATE_HOME:?XDG_STATE_HOME must be set before 40-apps.sh}"

export KITTY_CONFIG_DIRECTORY="${KITTY_CONFIG_DIRECTORY:-$XDG_CONFIG_HOME/kitty}"
export KITTY_CACHE_DIRECTORY="${KITTY_CACHE_DIRECTORY:-$XDG_CACHE_HOME/kitty}"
export EDITOR="${EDITOR:-$HOME/.local/bin/nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export ANDROID_USER_HOME="${ANDROID_USER_HOME:-$XDG_DATA_HOME/android}"
export PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$XDG_DATA_HOME/pass}"
export CODEX_HOME="${CODEX_HOME:-$XDG_DATA_HOME/codex}"
export CODEX_STATE="${CODEX_STATE:-$XDG_STATE_HOME/codex}"
export LESSHISTFILE="${LESSHISTFILE:-$XDG_STATE_HOME/lesshst}"
export GNUPGHOME="${GNUPGHOME:-$XDG_DATA_HOME/gnupg}"
