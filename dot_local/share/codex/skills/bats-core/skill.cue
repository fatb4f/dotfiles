// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "bats-core"
	title: "bats-core"
	purpose: "Bats black-box CLI behavior tests for shell CLIs and Bashly-generated command behavior."
	required_tools: []
	optional_tools: [
		"bats",
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
		"bats",
		"bats-core",
		"shell CLI tests",
		"exit code",
		"stdout",
		"stderr",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "bats-core/bats-core"
			ref: "master"
			url: "https://github.com/bats-core/bats-core"
			docs_url: "https://bats-core.readthedocs.io/"
			include: [
				"README.md",
				"docs",
				"man",
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
			output: "skills/bats-core"
		}
	}
}
