// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "shellspec"
	title: "shellspec"
	purpose: "ShellSpec unit/component tests for sourceable shell functions, helpers, mocks, and parameterized examples."
	required_tools: []
	optional_tools: [
		"shellspec",
	]
	phases: [
		"test_if_present",
	]
	deferred: true

	files: {
		prompt: "SKILL.md"
		references: [
			"SKILL.md",
			"AGENTS.md",
			"references/INDEX.md",
			"references/provenance.json",
			"references/docs",
			"references/patterns",
			"references/fixtures",
		]
	}

	triggers: [
		"shellspec",
		"shell unit test",
		"sourceable function",
		"mock",
		"parameterized example",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "shellspec/shellspec"
			ref: "master"
			url: "https://github.com/shellspec/shellspec"
			docs_url: "https://shellspec.info/"
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
				"references/fixtures",
			]
		}
	}

	adapters: {
		codex: {
			enabled: true
			output: "skills/shellspec"
		}
	}
}
