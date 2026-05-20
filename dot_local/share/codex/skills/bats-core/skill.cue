package skill

skill: {
	id: "bats-core"
	required_tools: []
	optional_tools: ["bats"]
	phases: ["test_if_present"]
	deferred: true
	gate_contribution: {
		blocks_on: ["bats_failed"]
	}
}
