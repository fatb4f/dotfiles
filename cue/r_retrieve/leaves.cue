package r_retrieve

import chezmoi "github.com/fatb4f/dotfiles/nodes/chezmoi"

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/retrieve/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:         string
	parentNode: "R"
	function:   "source-fact-catalog" | "retrieval-fixture"

	sourceSurface: string

	node: {
		id:   string
		root: string
	}

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	roundTrip: {
		toNodeContract: "R.contract"
		toRootGraph:    "root"
		backToLeaf:     string
	}

	invariants: [...string]
}

leaves: [...#Leaf] & [
	{
		"@id":         "ralph:leaf.chezmoi.source"
		id:            "leaf.chezmoi.source"
		parentNode:    "R"
		function:      "source-fact-catalog"
		sourceSurface: chezmoi.node.surfaces.source.path

		node: {
			id:   chezmoi.node.id
			root: chezmoi.node.root
		}

		roundTrip: {backToLeaf: "leaf.chezmoi.source"}

		invariants: [
			"chezmoi is a retrieval leaf source",
			"chezmoi leaf provides facts only",
			"chezmoi leaf does not authorize load",
			"chezmoi leaf does not authorize mutation",
		]
	},
]
