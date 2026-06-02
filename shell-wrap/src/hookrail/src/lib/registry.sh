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
hookrail_run_registry_execute() {
  local response_file response_json response_status adapter_binary adapter_transport cwd
  local adapter_stdout adapter_stderr adapter_exit_status export_status

  hookrail_need cue || return $?
  hookrail_need jq || return $?

  response_file="${args['--response']:-${args[response]:-}}"
  response_json="$(cat "$response_file")"
  response_status="$(jq -r '.status' "$response_file")"
  adapter_binary="$(jq -r '.request?.adapter?.binary // "mcp-adapter"' "$response_file")"
  adapter_transport="$(jq -r '.request?.adapter?.transport // "stdio"' "$response_file")"
  cwd="$(jq -r '.request?.cwd // "."' "$response_file")"

  if [[ "$response_status" != "selected" ]]; then
    jq -n \
      --argjson response "$response_json" \
      --arg adapterBinary "$adapter_binary" \
      --arg adapterTransport "$adapter_transport" \
      --arg reason "registry response is not selected" \
      '{
        schemaVersion: "cuerail.mcpExecutionEvidence.v1",
        response: $response,
        executionStatus: "forbidden",
        adapter: {
          binary: $adapterBinary,
          transport: $adapterTransport
        },
        reason: $reason
      }'
    return 1
  fi

  if ! command -v "$adapter_binary" >/dev/null 2>&1; then
    jq -n \
      --argjson response "$response_json" \
      --argjson request "$(jq '.request' "$response_file")" \
      --arg adapterBinary "$adapter_binary" \
      --arg adapterTransport "$adapter_transport" \
      --arg reason "missing MCP adapter binary" \
      '{
        schemaVersion: "cuerail.mcpExecutionEvidence.v1",
        response: $response,
        request: $request,
        executionStatus: "transport_failure",
        adapter: {
          binary: $adapterBinary,
          transport: $adapterTransport
        },
        reason: $reason
      }'
    return 127
  fi

  adapter_stdout="$(mktemp "${TMPDIR:-/tmp}/hookrail-registry-execute-stdout.XXXXXX.json")"
  adapter_stderr="$(mktemp "${TMPDIR:-/tmp}/hookrail-registry-execute-stderr.XXXXXX.log")"

  if (
    cd "$cwd" &&
    "$adapter_binary" <"$response_file" >"$adapter_stdout" 2>"$adapter_stderr"
  ); then
    :
  else
    adapter_exit_status=$?
    jq -n \
      --argjson response "$response_json" \
      --argjson request "$(jq '.request' "$response_file")" \
      --arg adapterBinary "$adapter_binary" \
      --arg adapterTransport "$adapter_transport" \
      --argjson exitCode "$adapter_exit_status" \
      --arg reason "MCP adapter exited non-zero" \
      --arg stdout "$(cat "$adapter_stdout")" \
      --arg stderr "$(cat "$adapter_stderr")" \
      '{
        schemaVersion: "cuerail.mcpExecutionEvidence.v1",
        response: $response,
        request: $request,
        executionStatus: "adapter_failure",
        adapter: {
          binary: $adapterBinary,
          transport: $adapterTransport
        },
        exitCode: $exitCode,
        stdout: $stdout,
        stderr: $stderr,
        reason: $reason
      }'
    rm -f "$adapter_stdout" "$adapter_stderr"
    return "$adapter_exit_status"
  fi

  if ! (cd "$(hookrail_repo_root)/cue/registry" && cue vet -c=false . "$adapter_stdout" -d "#RegistryExecutionEvidence" >/dev/null 2>&1); then
    jq -n \
      --argjson response "$response_json" \
      --argjson request "$(jq '.request' "$response_file")" \
      --arg adapterBinary "$adapter_binary" \
      --arg adapterTransport "$adapter_transport" \
      --argjson exitCode 0 \
      --arg reason "MCP adapter output did not validate" \
      --arg stdout "$(cat "$adapter_stdout")" \
      --arg stderr "$(cat "$adapter_stderr")" \
      '{
        schemaVersion: "cuerail.mcpExecutionEvidence.v1",
        response: $response,
        request: $request,
        executionStatus: "adapter_failure",
        adapter: {
          binary: $adapterBinary,
          transport: $adapterTransport
        },
        exitCode: $exitCode,
        stdout: $stdout,
        stderr: $stderr,
        reason: $reason
      }'
    rm -f "$adapter_stdout" "$adapter_stderr"
    return 1
  fi

  cat "$adapter_stdout"
  export_status=$?
  rm -f "$adapter_stdout" "$adapter_stderr"
  return "$export_status"
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
