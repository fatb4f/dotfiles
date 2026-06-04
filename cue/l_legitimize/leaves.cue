package l_legitimize

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/legitimize/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            string
	parentNode:    "L"
	function:      "legitimation-contract" | "promotion-gate-vocabulary" | "surface-authority-matrix"
	sourceSurface: string

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     bool | *false
		mayGrantMutationAdmissibility: bool | *false
		mayExecute:                    false
		mayPersist:                    false
	}

	roundTrip: {
		toNodeContract: "L.contract"
		toRootGraph:    "root"
		backToLeaf:     string
	}

	invariants: [...string]
}

leaves: [...#Leaf] & [
	{
		"@id":         "ralph:leaf.architecture.boundary"
		id:            "leaf.architecture.boundary"
		parentNode:    "L"
		function:      "surface-authority-matrix"
		sourceSurface: "cue/contracts/architecture.cue"
		authority: {mayGrantLoadAdmissibility: true, mayGrantMutationAdmissibility: true}
		roundTrip: {backToLeaf: "leaf.architecture.boundary"}
		invariants: ["contracts own policy", "adapters own no policy", "nodes/patterns/registry are non-authority"]
	},
	{
		"@id":         "ralph:leaf.agentflow.legitimation"
		id:            "leaf.agentflow.legitimation"
		parentNode:    "L"
		function:      "legitimation-contract"
		sourceSurface: "cue/contracts/agentflow/schema.cue"
		authority: {mayGrantLoadAdmissibility: false, mayGrantMutationAdmissibility: true}
		roundTrip: {backToLeaf: "leaf.agentflow.legitimation"}
		invariants: ["root response accepted", "promo requirements imported", "no direct registry loads before root acceptance"]
	},
	{
		"@id":         "ralph:leaf.promotion"
		id:            "leaf.promotion"
		parentNode:    "L"
		function:      "promotion-gate-vocabulary"
		sourceSurface: "cue/patterns/domain/schema.cue"
		roundTrip: {backToLeaf: "leaf.promotion"}
		invariants: ["promotion outcome derives by CUE unification", "rejected relations cannot satisfy promotion"]
	},
]
