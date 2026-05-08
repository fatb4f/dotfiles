# ~/.config/zsh/zload.zsh/named_dirs.zsh

emulate -L zsh

[[ -o interactive ]] || return 0

if (( $+functions[named_dirs_load] )); then
  named_dirs_load
else
  zstyle ':dotfiles:named-dirs' loaded false
  print -u2 -- 'zload: named_dirs_load unavailable'
fi
