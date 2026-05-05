# ~/.config/zsh/zload.zsh/env_import.zsh
# Import fallback-resolved environment into D-Bus/systemd activation env.

emulate -L zsh

env_import() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars

  (( ${#_dotfiles_env_import_vars[@]} )) || return 0
  command -v dbus-update-activation-environment >/dev/null 2>&1 || return 0

  dbus-update-activation-environment --systemd \
    "${_dotfiles_env_import_vars[@]}" \
    >/dev/null 2>&1 || return 0
}
