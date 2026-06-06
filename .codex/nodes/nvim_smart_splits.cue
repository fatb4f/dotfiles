package nodes

nvimSmartSplits: #LocalNodeContext & {
	id:         "nvim.smart-splits"
	role:       "local-node-context"
	sourcePath: "nodes/workspace/patterns/nvim_smart_splits.cue"
	domain:     "workspace"
	kind:       "pattern"

	surfaces: [
		{
			id:       "nvim.smart-splits.pattern"
			path:     "nodes/workspace/patterns/nvim_smart_splits.cue"
			function: "retrieval-card"
		},
	]

	retrievalHints: {
		matchedTerms: [
			"nvim",
			"smart-splits",
			"workspace",
		]
		relevantFiles: [
			"nodes/workspace/AGENTS.cue",
			"nodes/workspace/patterns/nvim_smart_splits.cue",
		]
		patternIDs: [
			"nvim.smart-splits",
		]
		stage: "verify"
	}

	negativeAuthority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	provenance: {
		generatedBy:    "R"
		sourceObserved: "nodes/workspace/patterns/nvim_smart_splits.cue"
		manifestID:     "local-node-context-normalization"
	}
}
