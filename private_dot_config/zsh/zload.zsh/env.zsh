# ~/.config/zsh/zload.zsh/env.zsh
# Single zsh environment resolver.
#
# State machine:
#   hotpath success → path
#   hotpath failure → parse → path → import

emulate -L zsh

_env_hotpath() {
  emulate -L zsh

  local expected_root
  expected_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/env"

  [[ "${DOTFILES_ENV_SBOM_ROOT:-}" == "$expected_root" ]]
}

_env_path() {
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

_env_parse() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars
  typeset -a env_files
  typeset env_file line name raw value

  env_files=("${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf(N.))
  (( ${#env_files[@]} )) || return 1

  for env_file in "${env_files[@]}"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%$'\r'}"

      [[ "$line" =~ '^[[:space:]]*($|#)' ]] && continue

      case "$line" in
        *=*) ;;
        *)
          print -u2 -- "env_parse: invalid line in $env_file: $line"
          return 2
          ;;
      esac

      name="${line%%=*}"
      raw="${line#*=}"

      case "$name" in
        ''|[0-9]*|*[!A-Za-z0-9_]*)
          print -u2 -- "env_parse: invalid variable name in $env_file: $name"
          return 2
          ;;
      esac

      # Compatibility for earlier shell-shaped generated files.
      if [[ "$raw" == '"'* && "$raw" == *'"' ]]; then
        raw="${raw#\"}"
        raw="${raw%\"}"
      fi

      # Safety gate for generated environment.d subset.
      case "$raw" in
        *'$('*|*'`'*|*'${('*|*';'*|*'"'*|*'\\'*)
          print -u2 -- "env_parse: unsupported expansion for $name in $env_file"
          return 2
          ;;
      esac

      # Trusted generated subset:
      #   $VAR, ${VAR}, ${VAR:-default}, ${VAR:+alternate}
      eval "value=\"$raw\""

      export "$name=$value"

      if (( ! ${_dotfiles_env_import_vars[(Ie)$name]} )); then
        _dotfiles_env_import_vars+=("$name")
      fi
    done < "$env_file"
  done

  return 0
}

_env_import() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars

  (( ${#_dotfiles_env_import_vars[@]} )) || return 0
  command -v dbus-update-activation-environment >/dev/null 2>&1 || return 0

  dbus-update-activation-environment --systemd \
    "${_dotfiles_env_import_vars[@]}" \
    >/dev/null 2>&1 || return 0
}

env_load() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars
  _dotfiles_env_import_vars=()

  if _env_hotpath; then
    zstyle ':dotfiles:env' loaded true
    zstyle ':dotfiles:env' authority environment.d

    _env_path
    return 0
  fi

  zstyle ':dotfiles:env' loaded false
  zstyle ':dotfiles:env' authority fallback

  if _env_parse; then
    _env_path
    _env_import
    return 0
  fi

  print -u2 -- 'zload: fallback env_parse failed'
  return 1
}
