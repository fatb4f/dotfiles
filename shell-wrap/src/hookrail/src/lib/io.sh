# shellcheck shell=bash

hookrail_need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'hookrail: missing required command: %s\n' "$1" >&2
    return 127
  }
}

hookrail_json_string() {
  jq -Rn --arg value "$1" '$value'
}

hookrail_read_stdin_json() {
  local out_file

  out_file="${1:?output path required}"
  cat >"$out_file"
  jq -e 'type == "object"' "$out_file" >/dev/null 2>&1
}

hookrail_wrap_input() {
  local input_file wrapped_file

  input_file="${1:?input path required}"
  wrapped_file="${2:?wrapped path required}"
  jq -c '{hookInput: .}' "$input_file" >"$wrapped_file"
}
