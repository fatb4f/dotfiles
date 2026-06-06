package nodes

workspaceProjections: #LocalNodeContext & {
	id:         "workspace.projections"
	role:       "local-node-context"
	sourcePath: "nodes/workspace/projections.cue"
	domain:     "workspace"
	kind:       "projection"

	surfaces: [
		{
			id:       "workspace.index"
			path:     "nodes/workspace/AGENTS.cue"
			function: "observed-source-surface"
		},
		{
			id:       "workspace.projections"
			path:     "nodes/workspace/projections.cue"
			function: "observed-projection-surface"
		},
	]

	retrievalHints: {
		matchedTerms: [
			"workspace",
			"root selection",
			"bounded discovery",
			"projected prompt",
		]
		relevantFiles: [
			"nodes/workspace/AGENTS.cue",
			"nodes/workspace/projections.cue",
			"nodes/workspace/patterns/wezterm_workspace.cue",
			"nodes/workspace/patterns/nvim_smart_splits.cue",
		]
		patternIDs: [
			"wezterm.workspace",
			"nvim.smart-splits",
		]
		stage: "assemble"
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
		sourceObserved: "nodes/workspace/projections.cue"
		manifestID:     "local-node-context-normalization"
	}
}
