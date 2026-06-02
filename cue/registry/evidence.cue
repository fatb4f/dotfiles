package registry

#RegistryExecutionStatus: "executed" | "tool_failure" | "transport_failure" | "adapter_failure" | "forbidden"

#RegistryExecutionEvidence: {
	schemaVersion: "cuerail.mcpExecutionEvidence.v1"
	response:      #RegistryResponse
	executionStatus: #RegistryExecutionStatus
	adapter: {
		binary:    string
		transport: "stdio"
	}
	request?: #ProjectedMCPToolRequestTemplate
	startedAt?: string
	finishedAt?: string
	exitCode?:   int
	stdout?:     string
	stderr?:     string
	error?:      string
	reason?:     string

	if response.status == "selected" {
		request: #ProjectedMCPToolRequestTemplate
		executionStatus: "executed" | "tool_failure" | "transport_failure" | "adapter_failure"
	}

	if response.status != "selected" {
		executionStatus: "forbidden"
		reason:          string
	}
}
