package h_harden

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      "ralph:H"
	"@type":    "ralph:PhaseManifest"

	id:    "H"
	label: "Harden"

	scope: {
		owns: ["durable lifecycle record", "accepted evidence distillation", "pattern promotion record", "retired ambiguity record"]
		mayRead: ["P.output.RunManifest", "leaf.lifecycle.closeout"]
		mayWrite: ["LifecycleRecord", "durable CUE state"]
		mayExecute: false
		mayPersist: true
	}

	boundaries: {
		upstream: ["P"]
		downstream: []
		forbidden: ["persist without accepted run", "promote rejected evidence", "promote ambiguity as fact", "write memory from adapter output alone"]
		authorityMode: "contract"
	}

	inputs: [{id: "runManifest", from: "P", kind: "RunManifest", acceptedRequired: true}]
	outputs: [{id: "lifecycleRecord", to: "durable-state", kind: "LifecycleRecord", acceptedBy: "H.accepted"}]

	control: {
		invariants: ["P.accepted == true", "sourceRunAccepted == true", "persisted == true", "distilled facts cite accepted evidence"]
		rejects: ["harden_without_accepted_run", "durable_write_from_unaccepted_manifest", "promotion_from_rejected_evidence"]
		acceptance: ["runAccepted == true", "persisted == true", "len(ambiguity) == 0"]
	}
}
