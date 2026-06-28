package impl

#CompletionReportSpec: close({
	primitives: [...string & !=""] & [_, ...]
	surfaces: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	commands: [...string & !=""] & [_, ...]
	evidence: [...string & !=""] & [_, ...]
})

#CompletionReportContract: close({
	kind: "completion-report-contract"
	requiredSections: [...string & !=""]
	expected: close({
		primitives: [...string & !=""]
		surfaces: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [...string & !=""]
		commands: [...string & !=""]
		evidence: [...string & !=""]
	})
})

#MakeCompletionReport: {
	in: #CompletionReportSpec

	out: #CompletionReportContract & {
		kind: "completion-report-contract"

		requiredSections: [
			"files changed",
			"primitives implemented",
			"surfaces implemented",
			"fixtures implemented",
			"bottom checks implemented",
			"commands run",
			"evidence",
			"final result",
		]

		expected: {
			primitives: in.primitives
			surfaces: in.surfaces
			fixtures: in.fixtures
			checks: in.checks
			commands: in.commands
			evidence: in.evidence
		}
	}
}
