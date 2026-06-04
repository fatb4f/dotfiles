package l_legitimize

goodLegitimation: #LegitimizePhase & {
	input: {flowContract: {id: "flow.good"}, flowContractAccepted: true}
	output: {
		rootSchema: {accepted: true, diagnostics: []}
		promoGate: {accepted: true, diagnostics: []}
		runnerBoundaries: {accepted: true}
		mutationAdmissibility: {accepted: true}
		ambiguity: []
	}
}

badAdapterPolicy: #ValidationFacts & {
	rootSchema: {accepted: true, diagnostics: []}
	promoGate: {accepted: true, diagnostics: []}
	runnerBoundaries: {accepted: false, adapterOwnsPolicy: true}
	mutationAdmissibility: {accepted: false}
	ambiguity: ["adapter_claims_policy"]
}
