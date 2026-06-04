package patterns

agentflowMutationGate: #Pattern & {
	id:      "agentflow_mutation_gate"
	summary: "Pre-mutation gate requiring accepted agentflow projection before scoped file edits."

	task: {
		objectiveClass: "mutation-admission"
		action:         "gate-mutation"
	}

	entities: [
		"dotfiles.workspace",
	]

	skills: [
		{
			id:   "git-workflow"
			role: "support"
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
			"required-mcp-tools",
		]
	}

	produces: {
		flowTasks: [
			"compose_contract",
			"vet_contract",
			"check_git_mutation",
		]
		projection: "cue/patterns/agentflow_mutation_gate.cue"
	}

	mutation: {
		allowed:            true
		admissionContract: "contracts.git.mutation"
	}
}
