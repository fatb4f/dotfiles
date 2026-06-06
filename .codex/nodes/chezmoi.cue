package nodes

chezmoi: #LocalNodeContext & {
	id:         "chezmoi"
	role:       "local-node-context"
	sourcePath: "nodes/chezmoi"
	domain:     "dotfiles-materialization"
	kind:       "node"

	surfaces: [
		{
			id:       "chezmoi.source"
			path:     "chezmoi"
			function: "source-tree"
		},
		{
			id:       "chezmoi.config"
			path:     "chezmoi.toml.tmpl"
			function: "config-template"
		},
	]

	retrievalHints: {
		matchedTerms: [
			"chezmoi",
			"dotfiles",
			"materialization",
		]
		relevantFiles: [
			"chezmoi",
			"chezmoi.toml.tmpl",
		]
		stage: "retrieve"
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
		sourceObserved: "nodes/chezmoi"
		manifestID:     "local-node-context-normalization"
	}
}
