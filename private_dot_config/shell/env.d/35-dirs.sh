# shellcheck shell=bash

DIRS="${DIRS-}"

_dirs_prepend() {
	case ":$DIRS:" in
	*":$1:"*) ;;
	*) DIRS="$1${DIRS:+:$DIRS}" ;;
	esac
}

DIR_SRC="${DIR_SRC:-$HOME/src}"
_dirs_prepend "$DIR_SRC"

export DIRS DIR_SRC
unset -f _dirs_prepend 2>/dev/null || true
