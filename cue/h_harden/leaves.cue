package h_harden

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            "leaf.lifecycle.closeout"
	parentNode:    "H"
	function:      "boundary-proof"
	sourceSurface: "cue/h_harden/contract.cue"

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	roundTrip: {
		toNodeContract: "H.contract"
		toRootGraph:    "root"
		backToLeaf:     "leaf.lifecycle.closeout"
	}

	invariants: [...string]
}

leaves: [#Leaf & {
	"@id": "ralph:leaf.lifecycle.closeout"
	invariants: ["boundary proof is input to H", "cue export is the final projection", "only accepted promotion evidence may be hardened"]
}]
