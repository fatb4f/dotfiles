package chezmoi

#ChezmoiNode: {
	id:     "chezmoi"
	kind:   "node"
	root:   "nodes/chezmoi"
	domain: "dotfiles-materialization"

	surfaces: {
		source: {
			id:       "chezmoi.source"
			path:     "chezmoi"
			function: "source-tree"
		}
		config: {
			id:       "chezmoi.config"
			path:     "chezmoi.toml.tmpl"
			function: "config-template"
		}
	}

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	invariants: [
		"chezmoi node is an entity/source fact surface",
		"chezmoi node does not authorize loads",
		"chezmoi node does not authorize mutation",
		"chezmoi node does not execute or persist",
	]
}

node: #ChezmoiNode
