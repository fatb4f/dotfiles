package h_harden

goodHarden: #HardenPhase & {
	input: {promotionCandidate: {id: "promotion.good"}, promotionAccepted: true}
	output: {
		id:                      "acceptedRunManifest.good"
		sourcePromotion:         "promotion.good"
		sourcePromotionAccepted: true
		boundaryProof: {
			noCustomRuntimeInvented:    true
			noAppServerBoundaryCrossed: true
			noUnacceptedMutationExport: true
			noUndeclaredMutation:       true
			noHiddenAppServerState:     true
			noCommitStackReasoning:     true
			cueExportBoundaryAccepted:  true
		}
		export: {command: "cue export", produces: "acceptedRunManifest"}
		ambiguity: []
	}
}

acceptedRunManifest: goodHarden.output

negativeRuntimeBoundaryInvented: {
	id: "acceptedRunManifest.bad.runtime"
	boundaryProof: {
		noCustomRuntimeInvented: false
	}
	ambiguity: [{kind: "runtime_boundary_invented", path: "H.boundaryProof", reason: "H may not accept a custom runtime boundary.", severity: "blocker"}]
}

negativeCommitStackReasoningIntroduced: {
	id: "acceptedRunManifest.bad.commit_stack"
	boundaryProof: {
		noCommitStackReasoning: false
	}
	ambiguity: [{kind: "commit_stack_reasoning_introduced", path: "H.boundaryProof", reason: "H does not own commit-stack or squash reasoning.", severity: "blocker"}]
}

negativeHiddenAppServerStateAssumed: {
	id: "acceptedRunManifest.bad.hidden_app_state"
	boundaryProof: {
		noHiddenAppServerState: false
	}
	ambiguity: [{kind: "hidden_app_server_state_assumed", path: "H.boundaryProof", reason: "H requires explicit boundary evidence.", severity: "blocker"}]
}

negativeDurableExportBeforeAcceptedState: {
	id:                      "acceptedRunManifest.bad.unaccepted"
	sourcePromotionAccepted: false
	ambiguity: [{kind: "durable_export_before_accepted_state", path: "P.accepted", reason: "H cannot export before P.accepted.", severity: "blocker"}]
}
