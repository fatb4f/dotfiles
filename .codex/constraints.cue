package workspace

#Constraints: {
	output:   #OutputConstraints
	workflow: #WorkflowConstraints
}

#OutputConstraints: {
	closeout: {
		required: [...string]
		order: [...string]
	}

	naming: {
		files:     "kebab-case" | "snake_case" | "preserve-existing"
		cueFields: "camelCase" | "snake_case"
		commands:  "argv-array"
	}

	style: {
		preferSmallDiffs:       bool | *true
		preserveExistingLayout: bool | *true
		noUnrequestedRenames:   bool | *true
	}
}

#WorkflowConstraints: {
	git: {
		required: bool | *true

		before: [...string] | *[
			"git status --short",
		]

		after: [...string] | *[
			"git diff --name-only",
			"git status --short",
		]

		forbidden: [...string] | *[
			"git commit",
			"git push",
			"git reset --hard",
		]
	}

	chezmoi: {
		required: bool | *true

		before: [...string] | *[
			"chezmoi status",
		]

		after: [...string] | *[
			"chezmoi diff",
			"chezmoi status",
		]

		forbidden: [...string] | *[
			"chezmoi apply",
			"chezmoi init",
		]
	}

	cue: {
		required: bool | *true

		checks: [...string] | *[
			"cue vet .codex/workspace.cue .codex/constraints.cue",
			"cue eval .codex/workspace.cue",
			"cue eval .codex/constraints.cue",
		]
	}
}

constraints: #Constraints & {
	output: {
		closeout: {
			required: [
				"selected domain",
				"files changed",
				"validations run",
				"validations skipped with reason",
			]

			order: [
				"selected domain",
				"matched surface",
				"files changed",
				"workflow state",
				"validations",
				"handoff",
			]
		}

		naming: {
			files:     "preserve-existing"
			cueFields: "camelCase"
			commands:  "argv-array"
		}
	}

	workflow: _
}
