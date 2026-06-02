package registry

#RegistryResponse: {
	status: "selected" | "none" | "ambiguous" | "blocked"
	query:  #RegistryQuery

	nodeID?:  string
	routeID?: string
	request?: #ProjectedMCPToolRequestTemplate
	gates?: [...#ValidationGate]
	errors?: [...#RegistryResolutionError]
	blockedCandidateIDs?: [...string]
}

#RenderedRegistrySelection: {
	resolution: #RegistryResolution

	status: resolution.status
	query:  resolution.query

	if status == "selected" {
		nodeID:  resolution.plan.node.id
		routeID: resolution.plan.route.id
		request: #ProjectedMCPToolRequestTemplate & {
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

#RegistryRequestOutput: #RegistryResponse

weztermResponse: #RegistryResponse & {
	status:  weztermResolution.status
	query:   weztermResolution.query
	nodeID:  weztermResolution.plan.node.id
	routeID: weztermResolution.plan.route.id
	request: #ProjectedMCPToolRequestTemplate & {
		server_cmd: weztermResolution.plan.request.server_cmd
		tool_name:  weztermResolution.plan.request.tool_name
		tool_args:  weztermResolution.plan.request.tool_args
		cwd:        weztermResolution.plan.request.cwd
		timeout_ms: weztermResolution.plan.request.timeout_ms
	}
	gates: weztermResolution.plan.gates
}

nestedWeztermResponse: #RegistryResponse & {
	status:  nestedWeztermResolution.status
	query:   nestedWeztermResolution.query
	nodeID:  nestedWeztermResolution.plan.node.id
	routeID: nestedWeztermResolution.plan.route.id
	request: #ProjectedMCPToolRequestTemplate & {
		server_cmd: nestedWeztermResolution.plan.request.server_cmd
		tool_name:  nestedWeztermResolution.plan.request.tool_name
		tool_args:  nestedWeztermResolution.plan.request.tool_args
		cwd:        nestedWeztermResolution.plan.request.cwd
		timeout_ms: nestedWeztermResolution.plan.request.timeout_ms
	}
	gates: nestedWeztermResolution.plan.gates
}

generatedBlockedResponse: #RegistryResponse & {
	status: generatedBlockedResolution.status
	query:  generatedBlockedResolution.query
	errors: generatedBlockedResolution.errors
	blockedCandidateIDs: [for _, candidate in generatedBlockedResolution.blockedCandidates {
		candidate.node.id
	}]
}

legacyBlockedResponse: #RegistryResponse & {
	status: legacyBlockedResolution.status
	query:  legacyBlockedResolution.query
	errors: legacyBlockedResolution.errors
	blockedCandidateIDs: [for _, candidate in legacyBlockedResolution.blockedCandidates {
		candidate.node.id
	}]
}

noMatchResponse: #RegistryResponse & {
	status: noMatchResolution.status
	query:  noMatchResolution.query
	errors: noMatchResolution.errors
}

ambiguousResponse: #RegistryResponse & {
	status: ambiguousResolution.status
	query:  ambiguousResolution.query
	errors: ambiguousResolution.errors
}
