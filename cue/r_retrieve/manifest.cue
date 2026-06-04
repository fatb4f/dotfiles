package r_retrieve

manifest: {
	id:    "R"
	label: "Retrieve"

	scope: {
		owns: [
			"source discovery",
			"fact classification",
			"ambiguity detection",
		]

		mayRead: [
			"leaf.chezmoi.source",
		]

		mayWrite: [
			"RetrievalContract",
		]

		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["root"]
		downstream: ["A"]

		forbidden: [
			"assemble graph",
			"authorize mutation",
			"execute adapter",
			"treat retrieved fact as authority",
		]

		authorityMode: "contract"
	}

	inputs: [
		{id: "objective", from: "root", kind: "objective"},
	]

	outputs: [
		{id: "retrievalContract", to: "A", kind: "RetrievalContract", acceptedBy: "R.accepted"},
	]

	control: {
		invariants: [
			"R emits facts only",
			"R does not assemble",
			"R does not execute",
			"R does not authorize mutation",
		]

		rejects: [
			"unbound_source",
			"legacy_source",
			"duplicate_authority",
		]

		acceptance: [
			"len(ambiguity) == 0",
		]
	}
}
