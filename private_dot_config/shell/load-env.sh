# shellcheck shell=bash
# Source-only shell environment loader for bash/zsh.
# Owns loading mechanics and helper primitives only.
# Env declarations belong in env.d/*.sh.

: "${HOME:?HOME is required}"

env_name_valid() {
	case "${1-}" in
	'' | *[!A-Za-z0-9_]* | [0-9]*) return 1 ;;
	*) return 0 ;;
	esac
}

env_export() {
	local name="${1-}"
	local value="${2-}"

	env_name_valid "$name" || return 2

	export "$name=$value"
}

env_export_dir() {
	local name="${1-}"
	local target="${2-}"

	env_name_valid "$name" || return 2
	[ -n "$target" ] || return 2

	target="${target%/}"
	[ -n "$target" ] || target="/"

	mkdir -p "$target" || return 1
	env_export "$name" "$target"
}

env_export_file() {
	local name="${1-}"
	local target="${2-}"
	local parent

	env_name_valid "$name" || return 2
	[ -n "$target" ] || return 2

	parent="${target%/*}"
	[ "$parent" = "$target" ] && parent="."

	mkdir -p "$parent" || return 1
	env_export "$name" "$target"
}

path_prepend() {
	local entry="${1-}"

	[ -n "$entry" ] || return 0

	case ":${PATH-}:" in
	*":$entry:"*) ;;
	*) PATH="$entry${PATH:+:$PATH}" ;;
	esac

	export PATH
}

path_prepend_dir() {
	local entry="${1-}"

	[ -n "$entry" ] || return 0

	mkdir -p "$entry" || return 1
	path_prepend "$entry"
}

shell_env_load() {
	local env_dir
	local env_file

	env_dir="${SHELL_ENV_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.d}"

	[ -d "$env_dir" ] || return 0

	if [ -n "${ZSH_VERSION-}" ]; then
		setopt LOCAL_OPTIONS NULL_GLOB
	fi

	for env_file in "$env_dir"/*.sh; do
		[ -f "$env_file" ] || continue

		# shellcheck source=/dev/null
		. "$env_file" || return
	done
}

shell_env_load "$@"
