# shellcheck shell=bash

hookrail_registry_export() {
  local overlay_file expression

  overlay_file="${1:?overlay file required}"
  expression="${2:?CUE expression required}"

  (cd "$(hookrail_repo_root)" && cue export "$overlay_file" -e "$expression" --out json)
}

hookrail_registry_resolve_overlay() {
  local overlay_file path objective allow_generated allow_legacy path_json objective_json

  overlay_file="${1:?overlay file required}"
  path="${2:?path required}"
  objective="${3:?objective required}"
  allow_generated="${4:-false}"
  allow_legacy="${5:-false}"

  path_json="$(hookrail_json_string "$path")"
  objective_json="$(hookrail_json_string "$objective")"

  cat >"$overlay_file" <<EOF
package registry

import reg "github.com/fatb4f/dotfiles/cue/registry"

resolution: reg.#RegistryResolution & {
  registry: reg.registry
  query: {
    path: $path_json
    objective: $objective_json
    allowGenerated: $allow_generated
    allowLegacy: $allow_legacy
  }
}

response: reg.#RegistryResponse & {
  status: resolution.status
  query:  resolution.query

  if status == "selected" {
    nodeID:  resolution.plan.node.id
    routeID: resolution.plan.route.id
    request: reg.#ProjectedMCPToolRequestTemplate & {
      server_cmd: resolution.plan.request.server_cmd
      tool_name:  resolution.plan.request.tool_name
      tool_args:  resolution.plan.request.tool_args
      cwd:        resolution.plan.request.cwd
      timeout_ms: resolution.plan.request.timeout_ms
    }
    gates: resolution.plan.gates
  }

  if status != "selected" {
    errors: resolution.errors

    if status == "blocked" {
      blockedCandidateIDs: [for _, candidate in resolution.blockedCandidates {
        candidate.node.id
      }]
    }
  }
}
EOF
}

# shellcheck disable=SC2154
hookrail_run_registry_resolve() {
  local overlay_file path objective allow_generated allow_legacy
  local export_status

  hookrail_need cue || return $?
  hookrail_need jq || return $?

  path="${args['--path']:-${args[path]:-}}"
  objective="${args['--objective']:-${args[objective]:-}}"
  if [[ -n ${args['--allow-generated']+x} ]]; then
    allow_generated=true
  else
    allow_generated=false
  fi
  if [[ -n ${args['--allow-legacy']+x} ]]; then
    allow_legacy=true
  else
    allow_legacy=false
  fi

  overlay_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-registry-resolve.XXXXXX.cue")"

  hookrail_registry_resolve_overlay \
    "$overlay_file" \
    "$path" \
    "$objective" \
    "$allow_generated" \
    "$allow_legacy"

  if hookrail_registry_export "$overlay_file" 'response'; then
    export_status=0
  else
    export_status=$?
  fi

  rm -f "$overlay_file"
  return "$export_status"
}
