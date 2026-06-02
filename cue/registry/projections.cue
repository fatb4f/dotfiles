package registry

// Local mirror of the frame-side MCP request envelope.
// The executable form adds runtime-only metadata such as `started_at`.
#ProjectedMCPToolRequestTemplate: {
	schemaVersion: "cuerail.mcpToolRequest.v1"
	kind:          "mcp.tool_request"

	adapter: {
		binary:    "mcp-adapter"
		transport: "stdio"
	}

	request_id?: string
	server_cmd: [...string]
	tool_name: string
	tool_args: [string]: _
	cwd:        string
	timeout_ms: int & >=0
	...
}

#ProjectedMCPToolRequest: #ProjectedMCPToolRequestTemplate

#ExecutableMCPToolRequest: #ProjectedMCPToolRequestTemplate & {
	started_at: string
}

#ProjectedSelection: {
	selection: #RegistrySelection
	projected: #ProjectedMCPToolRequestTemplate & {
		server_cmd: selection.plan.request.server_cmd
		tool_name:  selection.plan.request.tool_name
		tool_args:  selection.plan.request.tool_args
		cwd:        selection.plan.request.cwd
		timeout_ms: selection.plan.request.timeout_ms
	}
}

weztermExample: #ProjectedSelection & {
	selection: {
		registry: exampleRegistry
		query: {
			path:           "chezmoi/private_dot_config/wezterm/wezterm.lua"
			objective:      "inspect_config"
			allowGenerated: false
			allowLegacy:    false
		}
	}
	projected: #ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}

nestedWeztermExample: #ProjectedSelection & {
	selection: {
		registry: exampleRegistry
		query: {
			path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
			objective:      "inspect_config"
			allowGenerated: false
			allowLegacy:    false
		}
	}
	projected: #ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}

generatedAllowedExample: #ProjectedSelection & {
	selection: {
		registry: exampleRegistry
		query: {
			path:           "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
			objective:      "inspect_generated"
			allowGenerated: true
			allowLegacy:    false
		}
	}
	projected: #ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}

legacyAllowedExample: #ProjectedSelection & {
	selection: {
		registry: exampleRegistry
		query: {
			path:           "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
			objective:      "inspect_legacy"
			allowGenerated: false
			allowLegacy:    true
		}
	}
	projected: #ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}

exampleRegistry: registry
