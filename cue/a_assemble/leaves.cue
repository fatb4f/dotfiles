package a_assemble

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/assemble/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id: "leaf.flow.contract"
	parentNode: "A"
	function: "candidate-graph-schema"
	sourceSurface: "cue/flow/schema.cue"

	authority: {
		isRoot: false
		mayGrantLoadAdmissibility: false
		mayGrantMutationAdmissibility: false
		mayExecute: false
		mayPersist: false
	}

	roundTrip: {
		toNodeContract: "A.contract"
		toRootGraph: "root"
		backToLeaf: "leaf.flow.contract"
	}

	invariants: [...string]
}

leaves: [#Leaf & {
	"@id": "ralph:leaf.flow.contract"
	invariants: ["flow is a candidate graph leaf", "flow does not own lifecycle root", "flow does not grant mutation admissibility"]
}]
