package l_legitimize

goodLegitimation: #LegitimizePhase & {
	input: {taskGraphContract: {id: "taskGraph.good"}, taskGraphContractAccepted: true}
	output: {
		rootSchema: {accepted: true, diagnostics: []}
		promoGate: {accepted: true, diagnostics: []}
		runnerBoundaries: {accepted: true}
		mutationAdmissibility: {accepted: true}
		ambiguity: []
	}
}

badAdapterPolicy: {
	rootSchema: {accepted: true, diagnostics: []}
	promoGate: {accepted: true, diagnostics: []}
	runnerBoundaries: {accepted: false, adapterOwnsPolicy: true}
	mutationAdmissibility: {accepted: false}
	ambiguity: ["adapter_claims_policy"]
}
