# shellcheck shell=bash

: "${HOME:?HOME is required}"
: "${XDG_CONFIG_HOME:?XDG_CONFIG_HOME must be set before 30-toolchains.sh}"
: "${XDG_CACHE_HOME:?XDG_CACHE_HOME must be set before 30-toolchains.sh}"
: "${XDG_DATA_HOME:?XDG_DATA_HOME must be set before 30-toolchains.sh}"

export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$XDG_DATA_HOME/rustup}"

export GOPATH="${GOPATH:-$XDG_DATA_HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"

# npm / node userland tooling
export npm_config_userconfig="${npm_config_userconfig:-$XDG_CONFIG_HOME/npm/npmrc}"
export npm_config_cache="${npm_config_cache:-$XDG_CACHE_HOME/npm}"
export npm_config_prefix="${npm_config_prefix:-$XDG_DATA_HOME/npm}"

path_prepend "$npm_config_prefix/bin"
path_prepend "$CARGO_HOME/bin"
path_prepend "$GOBIN"
