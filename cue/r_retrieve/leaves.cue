package r_retrieve

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/retrieve/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            string
	parentNode:    "R"
	function:      "retrieval-interface" | "entity-fact-catalog" | "domain-fact-catalog" | "retrieval-fixture"
	sourceSurface: string

	authority: {
		isRoot: false
		mayGrantLoadAdmissibility: false
		mayGrantMutationAdmissibility: false
		mayExecute: false
		mayPersist: false
	}

	roundTrip: {
		toNodeContract: "R.contract"
		toRootGraph:     "root"
		backToLeaf:      string
	}

	invariants: [...string]
}

leaves: [...#Leaf] & [
	{
		"@id": "ralph:leaf.registry"
		id: "leaf.registry"
		parentNode: "R"
		function: "retrieval-interface"
		sourceSurface: "cue/registry/schema.cue"
		roundTrip: {backToLeaf: "leaf.registry"}
		invariants: ["returns selected/ambiguous/blocked/none", "does not authorize behavior"]
	},
	{
		"@id": "ralph:leaf.nodes"
		id: "leaf.nodes"
		parentNode: "R"
		function: "entity-fact-catalog"
		sourceSurface: "cue/nodes/schema.cue + cue/nodes/dotfiles/**"
		roundTrip: {backToLeaf: "leaf.nodes"}
		invariants: ["nodes classify entities", "nodes do not authorize loads", "nodes do not authorize mutation"]
	},
	{
		"@id": "ralph:leaf.patterns.domain_facts"
		id: "leaf.patterns.domain_facts"
		parentNode: "R"
		function: "domain-fact-catalog"
		sourceSurface: "cue/patterns/domain/*.cue"
		roundTrip: {backToLeaf: "leaf.patterns.domain_facts"}
		invariants: ["domain cards are facts/projections", "domain cards are not authority roots"]
	},
]
