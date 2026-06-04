package h_harden

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id: "leaf.lifecycle.closeout"
	parentNode: "H"
	function: "hardening-evidence"
	sourceSurface: "cue/patterns/lifecycle/schema.cue"

	authority: {
		isRoot: false
		mayGrantLoadAdmissibility: false
		mayGrantMutationAdmissibility: false
		mayExecute: false
		mayPersist: false
	}

	roundTrip: {
		toNodeContract: "H.contract"
		toRootGraph: "root"
		backToLeaf: "leaf.lifecycle.closeout"
	}

	invariants: [...string]
}

leaves: [#Leaf & {
	"@id": "ralph:leaf.lifecycle.closeout"
	invariants: ["closeout evidence is input to H", "closeout evidence is not durable memory by itself", "only accepted run evidence may be hardened"]
}]
