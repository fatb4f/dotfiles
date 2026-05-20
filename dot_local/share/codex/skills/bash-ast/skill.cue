// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "bash-ast"
	title: "bash-ast"
	purpose: "Optional Bash parse and semantic evidence using bash-ast or ast-bash."
	required_tools: []
	optional_tools: [
		"bash-ast",
		"ast-bash",
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
		"bash-ast",
		"ast-bash",
		"bash parser",
		"JSON AST",
		"parse evidence",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "cv/bash-ast"
			ref: "main"
			url: "https://github.com/cv/bash-ast"
			include: [
				"README.md",
				"HOMEBREW.md",
				"tests",
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
			output: "skills/bash-ast"
		}
	}
}
