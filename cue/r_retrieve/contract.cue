package r_retrieve

#SourceStatus: "active" | "legacy" | "deprecated" | "informational"

#Source: {
	id:         string
	path:       string
	status:     #SourceStatus
	selectable: bool | *true

	if status != "active" {
		selectable: false
	}
}

#Fact: {
	id:     string
	source: string
	claim:  string
}

#Evidence: {
	id:   string
	path: string
}

#AmbiguityKind:
	"unbound_source" |
	"legacy_source" |
	"duplicate_authority"

#Ambiguity: {
	kind:     #AmbiguityKind
	path:     string
	reason:   string
	severity: "blocker"
}

#RetrievalContract: {
	id: string

	sources: [...#Source]
	facts: [...#Fact]
	evidence: [...#Evidence]
	ambiguity: [...#Ambiguity]
}

#RetrievePhase: {
	id:   "R"
	name: "retrieve"

	input: {
		objective:         string
		rootAuthorityPath: string
	}

	output: #RetrievalContract

	accepted: len(output.ambiguity) == 0
}
