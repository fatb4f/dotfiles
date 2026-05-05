# ~/.config/zsh/zload.zsh/loader.zsh
# Single zsh environment resolver.
#
# State machine:
#   env_hotpath success → env_path
#   env_hotpath failure → env_parse → env_path → env_import

emulate -L zsh

typeset -ga _dotfiles_env_import_vars
_dotfiles_env_import_vars=()

_zload_dir="${${(%):-%N}:A:h}"
[[ -d "$_zload_dir" ]] || _zload_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/zload.zsh"

source "$_zload_dir/env_hotpath.zsh"
source "$_zload_dir/env_path.zsh"

if env_hotpath; then
  zstyle ':dotfiles:env' loaded true
  zstyle ':dotfiles:env' authority environment.d
  env_path
else
  zstyle ':dotfiles:env' loaded false
  zstyle ':dotfiles:env' authority fallback

  source "$_zload_dir/env_parse.zsh"
  source "$_zload_dir/env_import.zsh"

  if env_parse; then
    env_path
    env_import
  else
    print -u2 -- 'zload: fallback env_parse failed'
  fi
fi

unfunction env_hotpath env_parse env_path env_import 2>/dev/null || true
unset _dotfiles_env_import_vars _zload_dir
