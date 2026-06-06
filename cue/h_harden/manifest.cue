package h_harden

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      "ralph:H"
	"@type":    "ralph:PhaseManifest"

	id:    "H"
	label: "Harden"

	scope: {
		owns: ["final boundary proof", "accepted manifest projection", "cue export boundary"]
		mayRead: ["P.output.PromotionCandidate", "boundary evidence"]
		mayWrite: ["AcceptedRunManifest"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["P"]
		downstream: []
		forbidden: ["export without accepted promotion", "invent custom runtime", "cross app-server boundary", "assume hidden app-server state", "introduce commit-stack reasoning"]
		authorityMode: "contract"
	}

	inputs: [{id: "promotionCandidate", from: "P", kind: "PromotionCandidate", acceptedRequired: true}]
	outputs: [{id: "acceptedRunManifest", to: "cue export", kind: "AcceptedRunManifest", acceptedBy: "H.accepted"}]

	control: {
		invariants: ["P.accepted == true", "boundary proof accepted", "cue export is the final projection", "no undeclared mutation exported"]
		rejects: ["runtime_boundary_invented", "commit_stack_reasoning_introduced", "hidden_app_server_state_assumed", "durable_export_before_accepted_state"]
		acceptance: ["promotionAccepted == true", "boundaryProof accepted", "len(ambiguity) == 0"]
	}
}
