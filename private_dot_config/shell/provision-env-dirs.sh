#!/bin/sh
set -eu

: "${HOME:?HOME is required}"

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_DATA_BIN="${XDG_DATA_BIN:-$HOME/.local/bin}"
TOOL_PATH_HOME="${TOOL_PATH_HOME:-$XDG_DATA_HOME/path}"

install -d \
	"$XDG_CONFIG_HOME/shell" \
	"$XDG_CACHE_HOME/zsh" \
	"$XDG_STATE_HOME/zsh" \
	"$XDG_DATA_BIN" \
	"$TOOL_PATH_HOME" \
	"$XDG_DATA_HOME/cargo" \
	"$XDG_DATA_HOME/rustup" \
	"$XDG_DATA_HOME/go" \
	"$XDG_DATA_HOME/npm" \
	"$XDG_CONFIG_HOME/npm" \
	"$XDG_CACHE_HOME/npm" \
	"$XDG_DATA_HOME/codex" \
	"$XDG_STATE_HOME/codex" \
	"$XDG_DATA_HOME/gnupg"
