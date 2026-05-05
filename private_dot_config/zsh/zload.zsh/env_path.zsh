# ~/.config/zsh/zload.zsh/env_path.zsh
# PATH projection. No filesystem mutation.

emulate -L zsh

env_path() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars
  typeset -a entries prefix
  typeset entry

  entries=(
    "${XDG_DATA_BIN:-$HOME/.local/bin}"
    "${TOOL_PATH_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/path}"
    "${CARGO_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/cargo}/bin"
    "${GOBIN:-${XDG_DATA_HOME:-$HOME/.local/share}/go/bin}"
    "${npm_config_prefix:-${XDG_DATA_HOME:-$HOME/.local/share}/npm}/bin"
  )

  prefix=()
  for entry in "${entries[@]}"; do
    [[ -n "$entry" ]] || continue

    (( ${prefix[(Ie)$entry]} )) && continue

    case ":${PATH-}:" in
      *":$entry:"*) ;;
      *) prefix+=("$entry") ;;
    esac
  done

  if (( ${#prefix[@]} )); then
    PATH="${(j.:.)prefix}${PATH:+:$PATH}"
  fi

  export PATH

  if (( ! ${_dotfiles_env_import_vars[(Ie)PATH]} )); then
    _dotfiles_env_import_vars+=(PATH)
  fi
}
