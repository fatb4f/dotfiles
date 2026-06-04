package p_perform

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/perform/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            string
	parentNode:    "P"
	function:      "execution-evidence" | "adapter-execution-evidence"
	sourceSurface: string

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    bool | *false
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
		"@id":         "ralph:leaf.agentflow.run_manifest"
		id:            "leaf.agentflow.run_manifest"
		parentNode:    "P"
		function:      "execution-evidence"
		sourceSurface: "cue/contracts/agentflow/schema.cue"
		roundTrip: {backToLeaf: "leaf.agentflow.run_manifest"}
		invariants: ["all promo evidence cue-vetted", "all domain nodes accepted", "no mutation before gate"]
	},
	{
		"@id":         "ralph:leaf.registry.execution"
		id:            "leaf.registry.execution"
		parentNode:    "P"
		function:      "adapter-execution-evidence"
		sourceSurface: "cue/registry/evidence.cue"
		authority: {mayExecute: true}
		roundTrip: {backToLeaf: "leaf.registry.execution"}
		invariants: ["adapter execution is evidence", "adapter execution does not authorize behavior"]
	},
]
