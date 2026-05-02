# shellcheck shell=bash
# Noninteractive Bash adapter. Loaded through $BASH_ENV.

: "${HOME:?HOME is required}"

if [ -n "${__SHELL_ENV_LOADING:-}" ]; then
  return 0
fi

__SHELL_ENV_LOADING=1

: "${XDG_CONFIG_HOME:=$HOME/.config}"
export XDG_CONFIG_HOME

_shell_env_loader="${SHELL_ENV_LOADER:-$XDG_CONFIG_HOME/shell/load-env.sh}"
if [ -r "$_shell_env_loader" ]; then
  . "$_shell_env_loader"
fi

unset _shell_env_loader __SHELL_ENV_LOADING
