// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "sem"
	title: "sem"
	purpose: "Deterministic semantic repository intelligence for diffs, entities, context, impact, blame, and history."
	required_tools: [
		"sem",
	]
	optional_tools: [
		"jq",
	]
	phases: [
		"inspect",
		"semantic_diff",
		"impact",
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
		"sem",
		"semantic diff",
		"entity context",
		"impact analysis",
		"blast radius",
		"blame",
		"history",
	]

	references: {
		upstream: {
			kind: "github"
			repo: "Ataraxy-Labs/sem"
			ref: "main"
			url: "https://github.com/Ataraxy-Labs/sem"
			docs_url: "https://ataraxy-labs.github.io/sem/"
			include: [
				"README.md",
				"docs/llms.txt",
				"docs/agents.html",
				"docs/details.html",
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
			output: "skills/sem"
		}
	}
}
