package registry

#ProjectedMCPToolRequest: {
	schemaVersion: "cuerail.mcpToolRequest.v1"
	kind:         "mcp.tool_request"

	adapter: {
		binary:    "mcp-adapter"
		transport: "stdio"
	}

	request_id: string
	server_cmd: [...string]
	tool_name:  string
	tool_args:  [string]: _
	cwd:        string
	timeout_ms: int & >=0
	started_at: string
}

#ProjectedSelection: {
	selection: #RegistrySelection
	projected: #ProjectedMCPToolRequest & {
		request_id: selection.plan.request.request_id
		server_cmd: selection.plan.request.server_cmd
		tool_name:  selection.plan.request.tool_name
		tool_args:  selection.plan.request.tool_args
		cwd:        selection.plan.request.cwd
		timeout_ms: selection.plan.request.timeout_ms
	}
}
