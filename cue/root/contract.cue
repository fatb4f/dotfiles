package root

#PhaseID: "R" | "A" | "L" | "P" | "H"

#AuthorityMode: "root" | "contract" | "projection" | "interface" | "evidence" | "transport"

#NodeState: "waiting" | "ready" | "running" | "accepted" | "rejected"

#Edge: {
	from:     #PhaseID
	to:       #PhaseID
	requires: string
	meaning:  string
}

#LeafAuthority: {
	isRoot:                        false
	mayGrantLoadAdmissibility:     bool | *false
	mayGrantMutationAdmissibility: bool | *false
	mayExecute:                    bool | *false
	mayPersist:                    bool | *false
}

#LeafRef: {
	id:            string
	parentNode:    #PhaseID
	function:      string
	sourceSurface: string
	status:        "stay" | "adapt" | "compress" | "prune" | "split"

	authority: #LeafAuthority

	roundTrip: {
		toNodeContract: string
		toRootGraph:    "root"
		backToLeaf:     string
	}

	invariants: [...string]
}

#NodeIO: {
	id:               string
	from?:            string
	to?:              string
	kind:             string
	acceptedRequired: bool | *false
	acceptedBy?:      string
}

#NodeScope: {
	owns: [...string]
	mayRead: [...string]
	mayWrite: [...string]
	mayExecute: bool | *false
	mayPersist: bool | *false
}

#NodeBoundaries: {
	upstream: [...string]
	downstream: [...string]
	forbidden: [...string]
	authorityMode: #AuthorityMode
}

#NodeControl: {
	invariants: [...string]
	rejects: [...string]
	acceptance: [...string]
}

#GraphNodeContract: {
	"@context": "https://fatb4f.dev/ns/ralph/root/v0"
	"@id":      =~"^ralph:[A-Z]$"
	"@type":    "ralph:PhaseNode"

	id:    #PhaseID
	label: string
	state: #NodeState | *"waiting"

	scope:      #NodeScope
	boundaries: #NodeBoundaries
	inputs: [...#NodeIO]
	outputs: [...#NodeIO]
	control: #NodeControl
	leaves: [...#LeafRef]

	accepted: bool | *false
}

#RootLifecycleContract: {
	"@context": {
		"ralph":      "https://fatb4f.dev/ns/ralph#"
		"cue":        "https://cuelang.org/ns#"
		"phase":      "ralph:phase"
		"leaf":       "ralph:leaf"
		"precedes":   "ralph:precedes"
		"acceptedBy": "ralph:acceptedBy"
	}
	"@id":   "ralph:root"
	"@type": "ralph:RootLifecycle"

	schemaVersion: "dotfiles.ralph.root.v0"

	span: ["R", "A", "L", "P", "H"]

	authority: {
		root: "cue/root"
		R:    "cue/r_retrieve"
		A:    "cue/a_assemble"
		L:    "cue/l_legitimize"
		P:    "cue/p_perform"
		H:    "cue/h_harden"
	}

	edges: [
		{from: "R", to: "A", requires: "R.accepted", meaning: "accepted retrieval feeds assembly"},
		{from: "A", to: "L", requires: "A.accepted", meaning: "accepted graph feeds legitimation"},
		{from: "L", to: "P", requires: "L.accepted", meaning: "legitimized graph may perform"},
		{from: "P", to: "H", requires: "P.accepted", meaning: "accepted run evidence may harden"},
	]

	nodes: {
		R: #GraphNodeContract & {id: "R"}
		A: #GraphNodeContract & {id: "A"}
		L: #GraphNodeContract & {id: "L"}
		P: #GraphNodeContract & {id: "P"}
		H: #GraphNodeContract & {id: "H"}
	}

	invariants: [
		"R precedes A",
		"A precedes L",
		"L precedes P",
		"P precedes H",
		"no adapter execution before L.accepted",
		"no durable write before H",
		"contracts own policy",
		"metadata leaves never claim root authority",
	]
}

#AcceptedRootLifecycleContract: #RootLifecycleContract & {
	nodes: {
		R: accepted: true
		A: accepted: true
		L: accepted: true
		P: accepted: true
		H: accepted: true
	}
}
