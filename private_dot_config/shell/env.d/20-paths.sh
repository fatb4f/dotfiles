# shellcheck shell=sh

: "${HOME:?HOME is required}"
: "${XDG_DATA_HOME:?XDG_DATA_HOME must be set before 20-paths.sh}"

XDG_DATA_BIN="${XDG_DATA_BIN:-$HOME/.local/bin}"
TOOL_PATH_HOME="${TOOL_PATH_HOME:-$XDG_DATA_HOME/path}"

export XDG_DATA_BIN TOOL_PATH_HOME

path_prepend_dir "$XDG_DATA_BIN"
path_prepend_dir "$TOOL_PATH_HOME"
