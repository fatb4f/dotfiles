# ~/.config/zsh/zload.zsh/loader.zsh

emulate -L zsh

_zload_dir="${${(%):-%N}:A:h}"
[[ -d "$_zload_dir" ]] || _zload_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/zload.zsh"

source "$_zload_dir/env.zsh"
env_load

if [[ -o interactive ]]; then
  source "$_zload_dir/fpath.zsh"
  source "$_zload_dir/named_dirs.zsh"
fi

unfunction \
  env_load \
  _env_hotpath \
  _env_path \
  _env_parse \
  _env_import \
  2>/dev/null || true

unset _dotfiles_env_import_vars _zload_dir
