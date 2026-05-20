// Canonical per-skill contract for agent-sdk projection.
package skill

skill: {
	id: "agent-sdk"
	title: "agent-sdk"
	purpose: "Use agent-sdk to initialize, generate, check, and project managed agent runtimes and repo projects."
	required_tools: [
		"agentctl",
	]
	optional_tools: [
		"cue",
	]
	phases: [
		"init",
		"generate",
		"check",
	]

	files: {
		prompt: "SKILL.md"
		references: [
			"SKILL.md",
			"skill.cue",
			"references/INDEX.md",
			"references/provenance.json",
		]
	}

	triggers: [
		"agentctl",
		"agent-sdk",
		"agent runtime",
		"managed CODEX_HOME",
		"projection manifest",
	]

	references: {
		upstream: {
			kind: "local"
			source: "$AGENT_SDK_SOURCE"
			include: []
		}

		projected: {
			include: [
				"SKILL.md",
				"skill.cue",
				"references/INDEX.md",
				"references/provenance.json",
			]
		}
	}

	adapters: {
		codex: {
			enabled: true
			output: "skills/agent-sdk"
		}
	}
}
