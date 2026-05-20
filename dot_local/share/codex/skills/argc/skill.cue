// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "argc"
	title: "argc"
	purpose: "Argc annotation and argv-context guidance inside Bash source scripts."
	required_tools: []
	optional_tools: [
		"argc",
	]
	phases: [
		"inspect",
		"edit_source",
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
		"argc",
		"@cmd",
		"@arg",
		"@option",
		"@flag",
		"@env",
		"$argc_",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "sigoden/argc"
			ref: "main"
			url: "https://github.com/sigoden/argc"
			include: [
				"README.md",
				"docs",
				"examples",
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
			output: "skills/argc"
		}
	}
}
