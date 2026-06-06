package p_perform

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/promote/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            string
	parentNode:    "P"
	function:      "mutation-evidence" | "validation-evidence"
	sourceSurface: string

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	roundTrip: {
		toNodeContract: "P.contract"
		toRootGraph:    "root"
		backToLeaf:     string
	}

	invariants: [...string]
}

leaves: [...#Leaf] & [
	{
		"@id":         "ralph:leaf.promotion_candidate"
		id:            "leaf.promotion_candidate"
		parentNode:    "P"
		function:      "mutation-evidence"
		sourceSurface: "cue/p_perform/contract.cue"
		roundTrip: {backToLeaf: "leaf.promotion_candidate"}
		invariants: ["changed paths match task graph", "prior accepted states preserved"]
	},
	{
		"@id":         "ralph:leaf.validation_evidence"
		id:            "leaf.validation_evidence"
		parentNode:    "P"
		function:      "validation-evidence"
		sourceSurface: "cue/p_perform/fixtures.cue"
		roundTrip: {backToLeaf: "leaf.validation_evidence"}
		invariants: ["validations pass before export readiness", "missing validation rejects promotion"]
	},
]
