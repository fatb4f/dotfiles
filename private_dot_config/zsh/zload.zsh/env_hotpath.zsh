# ~/.config/zsh/zload.zsh/env_hotpath.zsh
# Hot-path environment readiness check.

emulate -L zsh

env_hotpath() {
  emulate -L zsh

  local expected_root
  expected_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/env"

  [[ "${DOTFILES_ENV_SBOM_ROOT:-}" == "$expected_root" ]]
}
