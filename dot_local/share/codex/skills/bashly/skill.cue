// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "bashly"
	title: "bashly"
	purpose: "Bashly source-edit workflow for Bashly config, source scripts, generated artifact boundaries, and CLI behavior reasoning."
	required_tools: [
		"bashly",
	]
	optional_tools: [
		"shellcheck",
		"shfmt",
		"shellharden",
	]
	phases: [
		"inspect",
		"edit_source",
		"generate",
		"validate",
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
		"bashly",
		"bashly.yml",
		"bashly generate",
		"generated CLI",
		"source-edit workflow",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "bashly-framework/bashly"
			ref: "master"
			url: "https://github.com/bashly-framework/bashly"
			docs_url: "https://bashly.dev/"
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
			output: "skills/bashly"
		}
	}
}
