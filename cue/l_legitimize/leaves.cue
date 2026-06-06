package l_legitimize

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/load/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            string
	parentNode:    "L"
	function:      "bounded-context" | "denied-load-evidence" | "surface-authority-matrix"
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
		authority: {mayGrantLoadAdmissibility: true, mayGrantMutationAdmissibility: false}
		roundTrip: {backToLeaf: "leaf.architecture.boundary"}
		invariants: ["contracts own policy", "adapters own no policy", "nodes/patterns/registry are non-authority"]
	},
	{
		"@id":         "ralph:leaf.loaded_context"
		id:            "leaf.loaded_context"
		parentNode:    "L"
		function:      "bounded-context"
		sourceSurface: "cue/l_legitimize/contract.cue"
		authority: {mayGrantLoadAdmissibility: true, mayGrantMutationAdmissibility: false}
		roundTrip: {backToLeaf: "leaf.loaded_context"}
		invariants: ["loaded files are selected or declared", "hidden authority loads are rejected"]
	},
	{
		"@id":         "ralph:leaf.denied_loads"
		id:            "leaf.denied_loads"
		parentNode:    "L"
		function:      "denied-load-evidence"
		sourceSurface: "cue/l_legitimize/fixtures.cue"
		roundTrip: {backToLeaf: "leaf.denied_loads"}
		invariants: ["sibling loads remain denied", "unbounded scans remain denied"]
	},
]
