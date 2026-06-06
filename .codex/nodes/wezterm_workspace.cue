package nodes

weztermWorkspace: #LocalNodeContext & {
	id:         "wezterm.workspace"
	role:       "local-node-context"
	sourcePath: "nodes/workspace/patterns/wezterm_workspace.cue"
	domain:     "workspace"
	kind:       "pattern"

	surfaces: [
		{
			id:       "wezterm.workspace.pattern"
			path:     "nodes/workspace/patterns/wezterm_workspace.cue"
			function: "retrieval-card"
		},
	]

	retrievalHints: {
		matchedTerms: [
			"wezterm",
			"workspace",
		]
		relevantFiles: [
			"nodes/workspace/AGENTS.cue",
			"nodes/workspace/patterns/wezterm_workspace.cue",
		]
		patternIDs: [
			"wezterm.workspace",
		]
		stage: "plan"
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
		sourceObserved: "nodes/workspace/patterns/wezterm_workspace.cue"
		manifestID:     "local-node-context-normalization"
	}
}
