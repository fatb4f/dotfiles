// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "shell-validation"
	title: "shell-validation"
	purpose: "Local shell validation: shellharden, shfmt, shellcheck, and pre-commit lint/format gates."
	required_tools: [
		"shfmt",
		"shellcheck",
	]
	optional_tools: [
		"shellharden",
	]
	phases: [
		"format",
		"lint_source",
	]

	files: {
		prompt: "SKILL.md"
		references: [
			"SKILL.md",
			"AGENTS.md",
			"references/INDEX.md",
			"references/provenance.json",
			"references/docs",
			"references/patterns",
		]
	}

	triggers: [
		"shellharden",
		"shfmt",
		"shellcheck",
		"shell validation",
		"pre-commit",
		"lint",
	]

	references: {
		upstream: {
			kind: "composite"
			repos: [
				{
					id: "shellcheck"
					repo: "koalaman/shellcheck"
					ref: "master"
					url: "https://github.com/koalaman/shellcheck"
					include: [
						"README.md",
						"wiki",
					]
				},
				{
					id: "shfmt"
					repo: "mvdan/sh"
					ref: "master"
					url: "https://github.com/mvdan/sh"
					include: [
						"README.md",
						"cmd/shfmt",
						"cmd/shfmt/shfmt.1.scd",
					]
				},
			]
			include: [
				"shellcheck/README.md",
				"shellcheck/wiki",
				"shfmt/README.md",
				"shfmt/cmd/shfmt",
				"shfmt/cmd/shfmt/shfmt.1.scd",
			]
		}

		projected: {
			include: [
				"SKILL.md",
				"AGENTS.md",
				"references/INDEX.md",
				"references/provenance.json",
				"references/docs",
				"references/patterns",
			]
		}
	}

	adapters: {
		codex: {
			enabled: true
			output: "skills/shell-validation"
		}
	}
}
