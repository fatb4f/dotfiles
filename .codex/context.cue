package codex

localContext: {
	role: "generated-local-context-rollup"

	cache: {
		path: ".codex/nodes"
		function: "normalized-local-node-context-cache"
		role: "local-context-cache"
	}

	nodes: [
		"chezmoi",
		"workspace.projections",
		"wezterm.workspace",
		"nvim.smart-splits",
	]

	manifestIDs: [
		"local-node-context-normalization",
	]

	negativeAuthority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
		mayDefinePolicy:               false
	}
}
