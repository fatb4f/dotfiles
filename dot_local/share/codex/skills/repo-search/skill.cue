// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "repo-search"
	title: "repo-search"
	purpose: "Bounded repository search before broad source inspection."
	required_tools: [
		"rg",
	]
	optional_tools: []
	phases: [
		"inspect",
	]

	files: {
		prompt: "SKILL.md"
		executables: [
			"repo-rg",
		]
		references: [
			"SKILL.md",
			"repo-rg",
			"references/INDEX.md",
			"references/provenance.json",
		]
	}

	triggers: [
		"repo-rg",
		"rg",
		"search repository",
		"find relevant files",
		"locate implementation surface",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "burntsushi/ripgrep"
			ref: "master"
			url: "https://github.com/BurntSushi/ripgrep"
			include: [
				"README.md",
				"GUIDE.md",
				"FAQ.md",
				"doc/rg.1.md",
			]
		}

		projected: {
			include: [
				"SKILL.md",
				"repo-rg",
				"references/INDEX.md",
				"references/provenance.json",
			]
		}
	}

	adapters: {
		codex: {
			enabled: true
			output: "skills/repo-search"
		}
	}
}
