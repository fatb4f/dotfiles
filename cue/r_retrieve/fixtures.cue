package r_retrieve

goodChezmoiRetrieval: #RetrievePhase & {
	input: {
		objective:         "Retrieve chezmoi source facts."
		rootAuthorityPath: "cue/root"
	}

	output: {
		id: "retrieval.chezmoi.good"

		sources: [
			{
				id:         "leaf.chezmoi.source"
				path:       "chezmoi"
				status:     "active"
				selectable: true
			},
		]

		facts: [
			{
				id:     "fact.chezmoi.source_surface"
				source: "leaf.chezmoi.source"
				claim:  "chezmoi is a dotfiles source/materialization surface"
			},
		]

		evidence: []
		ambiguity: []
	}
}

badLegacyChezmoiSource: #RetrievePhase & {
	input: {
		objective:         "Retrieve chezmoi source facts from a legacy source."
		rootAuthorityPath: "cue/root"
	}

	output: {
		id: "retrieval.chezmoi.bad.legacy"

		sources: [
			{
				id:     "leaf.chezmoi.legacy"
				path:   "cue/patterns/domain/chezmoi.cue"
				status: "legacy"
			},
		]

		facts: []
		evidence: []

		ambiguity: [
			{
				kind:     "legacy_source"
				path:     "cue/patterns/domain/chezmoi.cue"
				reason:   "legacy domain card cannot be selected as active R source"
				severity: "blocker"
			},
		]
	}
}

badUnboundChezmoiFact: #RetrievePhase & {
	input: {
		objective:         "Retrieve an unbound chezmoi fact."
		rootAuthorityPath: "cue/root"
	}

	output: {
		id: "retrieval.chezmoi.bad.unbound"

		sources: []

		facts: [
			{
				id:     "fact.chezmoi.unbound"
				source: "leaf.chezmoi.source"
				claim:  "This fact cites a source that was not admitted."
			},
		]

		evidence: []

		ambiguity: [
			{
				kind:     "unbound_source"
				path:     "leaf.chezmoi.source"
				reason:   "fact source is not present in active sources"
				severity: "blocker"
			},
		]
	}
}
