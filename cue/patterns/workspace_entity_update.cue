package patterns

workspaceEntityUpdate: #Pattern & {
	id:      "workspace_entity_update"
	summary: "Update repo-local entity descriptions without treating nodes as load or mutation authority."

	task: {
		objectiveClass: "entity-modeling"
		action:         "update-workspace-entities"
	}

	entities: [
		"dotfiles.workspace",
		"dotfiles.chezmoi",
		"dotfiles.shell-wrap",
	]

	skills: [
		{
			id:   "file-search"
			role: "support"
		},
		{
			id:   "git-workflow"
			role: "closeout"
		},
	]

	requires: {
		contracts: [
			"contracts.architecture",
			"contracts.lifecycle.proof",
		]
		gates: [
			"architecture-boundary",
			"lifecycle-proof",
		]
		evidence: [
			"loaded-files",
			"denied-loads",
			"validation-commands",
		]
	}

	produces: {
		flowTasks: [
			"resolve_patterns",
			"assemble_pattern_bundle",
			"compose_contract",
			"vet_contract",
			"project_agent_context",
			"record_lifecycle",
		]
		projection: "cue/patterns/workspace_entity_update.cue"
	}

	mutation: {
		allowed:           true
		admissionContract: "contracts.git.mutation"
	}
}
