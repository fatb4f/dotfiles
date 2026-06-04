package h_harden

goodHarden: #HardenPhase & {
	input: {runManifest: {id: "run.good"}, runAccepted: true}
	output: {
		id: "lifecycle.good"
		sourceRun: "run.good"
		sourceRunAccepted: true
		persisted: true
		distilledFacts: []
		promotedPatterns: []
		retiredAmbiguity: []
		ambiguity: []
	}
}

badHardenWithoutRun: #LifecycleRecord & {
	id: "lifecycle.bad.no_run"
	sourceRun: "run.rejected"
	sourceRunAccepted: true
	persisted: false
	distilledFacts: []
	promotedPatterns: []
	retiredAmbiguity: []
	ambiguity: [{kind: "harden_without_accepted_run", path: "P.output.RunManifest", reason: "Cannot persist without accepted run evidence.", severity: "blocker"}]
}
