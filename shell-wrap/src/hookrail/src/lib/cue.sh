# shellcheck shell=bash

hookrail_cue_export() {
  local wrapped_file expression

  wrapped_file="${1:?wrapped JSON path required}"
  expression="${2:?CUE expression required}"

  (cd "$(hookrail_cue_dir)" && cue export . "$wrapped_file" -e "$expression" --out json)
}

hookrail_project_output() {
  hookrail_cue_export "$1" '#HookProjection.output'
}

hookrail_project_manifest() {
  hookrail_cue_export "$1" '#HookProjection.manifest'
}

hookrail_project_persist() {
  hookrail_cue_export "$1" '#HookProjection.capture.persist'
}

hookrail_project_file_stem() {
  hookrail_cue_export "$1" '#HookProjection.capture.fileStem'
}
