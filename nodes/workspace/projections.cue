package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

_workspaceIndexFile: "nodes/workspace/AGENTS.cue"

rootSelectionResponse: agentnode.#RootSelectionResponse & {
	schemaVersion: "root.selectionResponse.v1"

	objective: "Route workspace requests through AGENTS.cue contracts without broad filesystem discovery."

	selected: [
		{
			nodeID:    node.node.id
			patternID: "wezterm.workspace"
			stage:     "plan"
			rationale: node.authority.taskPatterns[0].rationale
			matchedTerms: ["workspace", "wezterm"]
			loadableFiles: [
				_workspaceIndexFile,
				node.authority.taskPatterns[0].path,
			]
			requires: node.authority.taskPatterns[0].requires
		},
		{
			nodeID:    node.node.id
			patternID: "nvim.smart-splits"
			stage:     "verify"
			rationale: node.authority.taskPatterns[1].rationale
			matchedTerms: ["workspace", "smart-splits"]
			loadableFiles: [
				_workspaceIndexFile,
				node.authority.taskPatterns[1].path,
			]
			requires: node.authority.taskPatterns[1].requires
		},
	]

	forbiddenLoads: node.authority.forbiddenLoads

	evidence: {
		rootMCPAvailable: true
		selectionMode:    "root-mediated"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
		authorizationSource: "root-policy"
		selectedPatternIDs: [
			node.authority.taskPatterns[0].id,
			node.authority.taskPatterns[1].id,
		]
		loadedFiles: [
			{
				path:         _workspaceIndexFile
				authorizedBy: "root-policy"
				reason:       "Root index selected the workspace AgentNode contract before task-owned files were loaded."
			},
			{
				path:            node.authority.taskPatterns[0].path
				authorizedBy:    "selected-pattern"
				sourcePatternID: node.authority.taskPatterns[0].id
				reason:          "Selected pattern metadata authorizes this pattern card."
			},
			{
				path:            node.authority.taskPatterns[1].path
				authorizedBy:    "selected-pattern"
				sourcePatternID: node.authority.taskPatterns[1].id
				reason:          "Selected pattern metadata authorizes this pattern card."
			},
		]
		deniedLoads: [
			{
				path:        "nodes/workspace/patterns/unselected_neighbor.cue"
				reason:      "Arbitrary neighboring files are not authorized by root selection or selected pattern metadata."
				requestedBy: "neighboring-file probe"
			},
			{
				path:        "** via unbounded rg --files"
				reason:      "Broad discovery requests are outside the root-mediated AgentNode contract."
				requestedBy: "broad discovery request"
			},
		]
		rationale: "Root policy selected workspace task patterns from declared AGENTS.cue metadata and limited loads to the root index plus selected pattern files."
	}
}

boundedDiscoveryFixture: rootSelectionResponse & {
	evidence: {
		selectionMode: "root-mediated"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
	}
	forbiddenLoads: [
		"chezmoi/**",
		"**/AGENTS.md recursive",
		"** via unbounded rg --files",
	]
}

fallbackDiscoveryFixture: agentnode.#RootSelectionResponse & {
	schemaVersion: "root.selectionResponse.v1"

	objective: "Route workspace requests through explicitly named index files only when root MCP selection is unavailable."

	selected: []

	forbiddenLoads: node.authority.forbiddenLoads

	evidence: {
		rootMCPAvailable: false
		selectionMode:    "fallback-metadata"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
		authorizationSource: "fallback-explicit-index"
		selectedPatternIDs: []
		loadedFiles: [
			{
				path:         "AGENTS.cue"
				authorizedBy: "fallback-explicit-index"
				reason:       "Fallback mode permits only explicitly named root index files when root MCP selection is unavailable."
			},
			{
				path:         _workspaceIndexFile
				authorizedBy: "fallback-explicit-index"
				reason:       "Fallback mode permits only explicitly named node index files when root MCP selection is unavailable."
			},
		]
		deniedLoads: [
			{
				path:        "nodes/workspace/patterns/wezterm_workspace.cue"
				reason:      "Fallback explicit-index mode does not authorize task pattern files without root mediation or user grant."
				requestedBy: "fallback pattern-file probe"
			},
			{
				path:        "** via unbounded rg --files"
				reason:      "Fallback mode remains bounded and denies broad discovery requests."
				requestedBy: "broad discovery request"
			},
		]
		rationale: "Root MCP selection is unavailable, so fallback evidence is limited to explicitly named index files and denial records."
	}
}

projectedPrompt: agentnode.#ProjectedPrompt & {
	schemaVersion: "agentNode.projectedPrompt.v1"
	text: """
		Use AGENTS.cue/root MCP selections as the machine-readable authority.
		AGENTS.md is narrative guidance only.
		Do not inspect task-owned files until root mediation selects a task pattern.
		If root MCP is unavailable, use only explicitly named AGENTS.cue/index files or user-granted paths.
		Record selected patterns, loaded files, rationale, and fallback mode.
		"""
}
