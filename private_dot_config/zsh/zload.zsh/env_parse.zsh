# ~/.config/zsh/zload.zsh/env_parse.zsh
# Parse generated environment.d conf files into the current zsh process.
# This is a fallback adapter for trusted/generated files, not a general-purpose parser.

emulate -L zsh

env_parse() {
  emulate -L zsh

  typeset -ga _dotfiles_env_import_vars
  typeset -a env_files
  typeset env_file line name raw value

  env_files=("${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf(N.))
  (( ${#env_files[@]} )) || return 1

  for env_file in "${env_files[@]}"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Drop CR from CRLF files.
      line="${line%$'\r'}"

      # Blank/comment lines.
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

      # Optional compatibility for earlier shell-shaped generated files.
      # environment.d itself does not require or interpret shell quotes.
      if [[ "$raw" == '"'*'"' && "$raw" == *'"' ]]; then
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

      # Evaluate trusted parameter expansion forms used by environment.d:
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
