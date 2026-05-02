# shellcheck shell=bash
if [[ -d "$HOME/.local/share/cargo" ]]; then
	export CARGO_HOME="${CARGO_HOME:-$HOME/.local/share/cargo}"
else
	export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
fi

if [[ -d "$HOME/.local/share/rustup" ]]; then
	export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.local/share/rustup}"
else
	export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
fi

export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"

if [[ -d "$CARGO_HOME/bin" ]]; then
	path_prepend "$CARGO_HOME/bin"
fi

path_prepend "$HOME/.go/bin"
path_prepend "$GOBIN"

# shellcheck disable=SC1091
if [[ -f "$HOME/.cargo/env" ]]; then
	. "$HOME/.cargo/env"
fi

if command -v gcc >/dev/null 2>&1; then
	CC="$(command -v gcc)"
	export CC
else
	unset CC
fi

if command -v g++ >/dev/null 2>&1; then
	CXX="$(command -v g++)"
	export CXX
else
	unset CXX
fi
