package r_retrieve

#AuthoritySourceStatus: "active" | "legacy" | "deprecated" | "informational"

#AuthoritySource: {
	id:         string
	path:       string
	status:     #AuthoritySourceStatus
	selectable: bool

	if status != "active" {
		selectable: false
	}
}

#RetrievedFact: {
	id:     string
	source: string
	claim:  string
}

#EvidenceRef: {
	id:   string
	path: string
}

#AmbiguityFinding: {
	kind: "unbound_source" | "legacy_source_selectable" | "duplicate_authority" | "keyword_relevance_authorizes_load" | "direct_registry_load_before_root_acceptance"
	path: string
	reason: string
	severity: "blocker"
}

#RetrievalContract: {
	id: string

	admissibleSources: [...#AuthoritySource]
	retrievedFacts:     [...#RetrievedFact]
	priorEvidence:      [...#EvidenceRef]
	patternRefs:        [...#EvidenceRef]
	nodeFacts:          [...#EvidenceRef]

	ambiguity: [...#AmbiguityFinding]
}

#RetrievePhase: {
	"@context": "https://fatb4f.dev/ns/ralph/retrieve/v0"
	"@id":      "ralph:R"
	"@type":    "ralph:PhaseNode"

	id:   "R"
	name: "retrieve"

	input: {
		objective:         string
		rootAuthorityPath: string
	}

	output: #RetrievalContract

	accepted: len(output.ambiguity) == 0

	control: {
		invariants: [
			"R defines what facts may be used by A",
			"R does not assemble the candidate graph",
			"registry is interface only",
			"nodes are entity facts only",
		]
	}
}
