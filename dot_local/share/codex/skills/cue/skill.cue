// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "cue"
	title: "CUE"
	purpose: "Use CUE as schema, validation, graph, and projection authority."
	required_tools: [
		"cue",
	]
	optional_tools: []
	phases: [
		"inspect",
		"validate",
		"generate",
	]

	files: {
		prompt: "SKILL.md"
		references: [
			"SKILL.md",
			"references/INDEX.md",
			"references/provenance.json",
			"references/docs",
			"references/patterns",
			"references/fixtures",
		]
	}

	triggers: [
		"cue",
		"agent.cue",
		"schema",
		"projection graph",
		"validation",
		"generated surface",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "cue-lang/cue"
			ref: "master"
			url: "https://github.com/cue-lang/cue"
			docs_repos: [
				{
					repo: "cue-lang/cuelang.org"
					ref: "master"
					url: "https://github.com/cue-lang/cuelang.org"
				},
			]
			include: [
				"doc/ref/spec.md",
				"doc/ref/impl.md",
				"doc/cmd/cue.md",
				"doc/context/language-features.md",
				"doc/tutorial/basics/README.md",
			]
		}

		projected: {
			include: [
				"SKILL.md",
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
			output: "skills/cue"
		}
	}
}
