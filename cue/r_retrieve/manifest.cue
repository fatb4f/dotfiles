package r_retrieve

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/retrieve/v0"
	"@id":      "ralph:R"
	"@type":    "ralph:PhaseManifest"

	id:    "R"
	label: "Retrieve"

	scope: {
		owns: ["admissible source discovery", "retrieved fact classification", "ambiguity detection"]
		mayRead: ["leaf.registry", "leaf.nodes", "leaf.patterns.domain_facts", "prior evidence"]
		mayWrite: ["RetrievalContract"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["root"]
		downstream: ["A"]
		forbidden: ["assemble graph", "authorize mutation", "execute adapter", "treat registry selection as authority"]
		authorityMode: "contract"
	}

	inputs: [{id: "objective", from: "root", kind: "objective", acceptedRequired: false}]
	outputs: [{id: "retrievalContract", to: "A", kind: "RetrievalContract", acceptedBy: "R.accepted"}]

	control: {
		invariants: ["facts cite admissible sources", "legacy sources are not selectable by default", "keyword relevance is not authorization"]
		rejects: ["unbound_source", "legacy_source_selectable", "duplicate_authority", "keyword_relevance_authorizes_load"]
		acceptance: ["len(ambiguity) == 0", "all selected sources are active"]
	}
}
