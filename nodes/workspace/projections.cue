package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

rootSelectionResponse: agentnode.#RootSelectionResponse & {
	schemaVersion: "root.selectionResponse.v1"

	objective: "Route workspace requests through AGENTS.cue contracts without broad filesystem discovery."

	selected: [
		{
			nodeID:       node.node.id
			patternID:    "wezterm.workspace"
			stage:        "plan"
			rationale:    node.authority.taskPatterns[0].rationale
			matchedTerms: ["workspace", "wezterm"]
			loadableFiles: [
				"nodes/workspace/AGENTS.cue",
				"nodes/workspace/patterns/wezterm_workspace.cue",
			]
			requires: node.authority.taskPatterns[0].requires
		},
		{
			nodeID:       node.node.id
			patternID:    "nvim.smart-splits"
			stage:        "verify"
			rationale:    node.authority.taskPatterns[1].rationale
			matchedTerms: ["workspace", "smart-splits"]
			loadableFiles: [
				"nodes/workspace/AGENTS.cue",
				"nodes/workspace/patterns/nvim_smart_splits.cue",
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
			"nodes/workspace/AGENTS.cue",
		]
	}
}

boundedDiscoveryFixture: rootSelectionResponse & {
	evidence: {
		selectionMode: "root-mediated"
		indexSources: [
			"AGENTS.cue",
			"nodes/workspace/AGENTS.cue",
		]
	}
	forbiddenLoads: [
		"chezmoi/**",
		"**/AGENTS.md recursive",
		"** via unbounded rg --files",
	]
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
