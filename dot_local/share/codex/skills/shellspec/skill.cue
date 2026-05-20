package skill

skill: {
	id: "shellspec"
	required_tools: []
	optional_tools: ["shellspec"]
	phases: ["test_if_present"]
	deferred: true
	gate_contribution: {
		blocks_on: ["shellspec_failed"]
	}
}
