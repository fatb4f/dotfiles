package r_retrieve

goodRetrieval: #RetrievePhase & {
	input: {
		objective:         "Review graph node authority."
		rootAuthorityPath: "cue/root"
	}
	output: {
		id: "retrieval.good"
		admissibleSources: [{id: "registry", path: "cue/registry/schema.cue", status: "active", selectable: true}]
		retrievedFacts: [{id: "fact.registry.interface_only", source: "registry", claim: "Registry returns candidates but does not authorize behavior."}]
		priorEvidence: []
		patternRefs: []
		nodeFacts: []
		ambiguity: []
	}
}

badLegacySelectable: {
	id: "retrieval.bad.legacy"
	admissibleSources: [{id: "legacy-flow", path: "cue/flow", status: "legacy", selectable: true}]
	retrievedFacts: []
	priorEvidence: []
	patternRefs: []
	nodeFacts: []
	ambiguity: [{kind: "legacy_source_selectable", path: "cue/flow", reason: "Legacy source cannot remain selectable.", severity: "blocker"}]
}
