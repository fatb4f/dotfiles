# ~/.config/zsh/zload.zsh/fpath.zsh

emulate -L zsh

_zfunc_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/fn"

if [[ -d "$_zfunc_dir" ]]; then
  if (( ! ${fpath[(Ie)$_zfunc_dir]} )); then
    fpath=("$_zfunc_dir" "${fpath[@]}")
  fi

  local fn
  for fn in "$_zfunc_dir"/*(.N:t); do
    autoload -Uz "$fn"
  done

  zstyle ':dotfiles:fpath' loaded true
  zstyle ':dotfiles:fpath' dir "$_zfunc_dir"
else
  zstyle ':dotfiles:fpath' loaded false
  zstyle ':dotfiles:fpath' dir "$_zfunc_dir"
  print -u2 -- "zload: missing function dir: $_zfunc_dir"
fi

unset _zfunc_dir fn
