package r_retrieve

import chezmoi "github.com/fatb4f/dotfiles/nodes/chezmoi"

#Leaf: {
	id:         string
	parentNode: "R"
	function:   "source-surface"
	nodeID:     string

	sourceSurface: string

	authority: {
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	invariants: [...string]
}

leaves: [
	#Leaf & chezmoi.retrieveLeaf,
]
