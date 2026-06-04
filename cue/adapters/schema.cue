package adapters

#MCPAccessBoundary: {
	id: "cue-flow-mcp"

	transport: "mcp"

	roles: {
		rag:            true
		flowComposer:   true
		gitObservation: true
		gitMutation: {
			reachable:                  true
			admissibleOnlyWithContract: true
		}
	}

	invariants: {
		isAccessBoundary:            true
		isTransportOnly:             true
		ownsPolicy:                  false
		grantsLoadAdmissibility:     false
		grantsMutationAdmissibility: false
		mutationRequiresContract:    true
	}
}

cueFlowMCP: #MCPAccessBoundary
