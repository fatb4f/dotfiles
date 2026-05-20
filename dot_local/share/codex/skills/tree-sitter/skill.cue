// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "tree-sitter"
	title: "tree-sitter"
	purpose: "Optional structural inspection evidence for source edits using tree-sitter-cli."
	required_tools: []
	optional_tools: [
		"tree-sitter",
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
			"references/fixtures",
		]
	}

	triggers: [
		"tree-sitter",
		"structural inspection",
		"parse tree",
		"syntax tree",
		"AST evidence",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "tree-sitter/tree-sitter"
			ref: "master"
			url: "https://github.com/tree-sitter/tree-sitter"
			docs_url: "https://tree-sitter.github.io/tree-sitter/"
			include: [
				"README.md",
				"docs",
				"cli",
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
			output: "skills/tree-sitter"
		}
	}
}
