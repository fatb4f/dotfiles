# shellcheck shell=bash
export DIRS=""

dirs_prepend() {
	case ":$DIRS:" in
	*":$1:"*) ;;
	*) DIRS="$1${DIRS:+:$DIRS}" ;;
	esac
}

export DIR_SRC="${DIR_SRC:-$HOME/src}"
dirs_prepend "$DIR_SRC"

