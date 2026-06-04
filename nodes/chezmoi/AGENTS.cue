package chezmoi

node: {
	id:     "chezmoi"
	domain: "dotfiles-materialization"
	root:   "chezmoi"

	surfaces: {
		source: {
			id:   "chezmoi.source"
			path: "chezmoi"
			kind: "source-tree"
		}
		config: {
			id:   "chezmoi.config"
			path: "chezmoi.toml.tmpl"
			kind: "template"
		}
		rootMarker: {
			id:   "chezmoi.root-marker"
			path: ".chezmoiroot"
			kind: "root-marker"
		}
	}

	authority: {
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}
}

retrieveLeaf: {
	id:            "leaf.chezmoi.source"
	parentNode:    "R"
	function:      "source-surface"
	sourceSurface: node.surfaces.source.path
	nodeID:        node.id

	authority: node.authority

	invariants: [
		"chezmoi is a source/materialization surface",
		"chezmoi source facts do not authorize mutation",
		"chezmoi source facts do not assemble the task graph",
		"full recursive chezmoi scans require an accepted Retrieve contract",
	]
}
