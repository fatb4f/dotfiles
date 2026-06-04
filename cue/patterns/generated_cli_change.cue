package patterns

generatedCliChange: #Pattern & {
	id:      "generated_cli_change"
	summary: "Generated CLI change across shell adapter sources, CUE projections, and git closeout."

	task: {
		objectiveClass: "source-change"
		action:         "mutate-generated-cli-surface"
	}

	entities: [
		"dotfiles.shell-wrap",
		"dotfiles.workspace",
	]

	skills: [
		{
			id:   "bashly-workflow"
			role: "primary"
		},
		{
			id:   "git-workflow"
			role: "closeout"
		},
	]

	requires: {
		contracts: [
			"contracts.agentflow.premutation",
			"contracts.git.mutation",
		]
		gates: [
			"agentflow-premutation",
			"git-mutation-admission",
		]
		evidence: [
			"loaded-files",
			"validation-commands",
			"git-status",
			"git-diff",
		]
	}

	produces: {
		flowTasks: [
			"resolve_patterns",
			"assemble_pattern_bundle",
			"compose_contract",
			"vet_contract",
			"check_git_mutation",
			"record_lifecycle",
		]
		projection: "cue/patterns/generated_cli_change.cue"
	}

	mutation: {
		allowed:           true
		admissionContract: "contracts.git.mutation"
	}
}
