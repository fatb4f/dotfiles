package skill

skill: {
	id: "shell-validation"
	required_tools: ["shfmt", "shellcheck"]
	optional_tools: ["shellharden"]
	phases: ["format", "lint_source"]
	gate_contribution: {
		blocks_on: ["shfmt_failed", "shellcheck_source_failed"]
	}
}
