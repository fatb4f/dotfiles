package patterns

gitCloseout: #Pattern & {
	id:      "git_closeout"
	summary: "Task-scoped git status, diff, staging, commit, and final status evidence."

	task: {
		objectiveClass: "repo-closeout"
		action:         "record-git-evidence"
	}

	entities: [
		"dotfiles.workspace",
	]

	skills: [
		{
			id:   "git-workflow"
			role: "closeout"
		},
	]

	requires: {
		contracts: [
			"contracts.git.evidence",
			"contracts.lifecycle.proof",
		]
		gates: [
			"git-closeout",
			"lifecycle-proof",
		]
		evidence: [
			"git-status",
			"git-diff",
			"lifecycle-record",
		]
	}

	produces: {
		flowTasks: [
			"record_lifecycle",
		]
		projection: "cue/patterns/git_closeout.cue"
	}

	mutation: {
		allowed:            true
		admissionContract: "contracts.git.mutation"
	}
}
