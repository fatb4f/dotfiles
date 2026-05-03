# shellcheck shell=bash

: "${XDG_DATA_HOME:=$HOME/.local/share}"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"

# npm / node userland tooling
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export npm_config_prefix="$XDG_DATA_HOME/npm"

path_prepend "$npm_config_prefix/bin"
path_prepend "$CARGO_HOME/bin"
path_prepend "$GOBIN"

# shellcheck disable=SC1091
if [[ -f "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi

if command -v gcc >/dev/null 2>&1; then
  export CC
  CC="$(command -v gcc)"
else
  unset CC
fi

if command -v g++ >/dev/null 2>&1; then
  export CXX
  CXX="$(command -v g++)"
else
  unset CXX
fi
