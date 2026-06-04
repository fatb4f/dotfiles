package domain

shellWrap: #EntityProjection & {
	id:   "shell-wrap"
	area: "shell-wrap"

	surface: {
		summary: "shell-wrap/src/hookrail command-surface"
		paths: [
			"shell-wrap/src/hookrail",
		]
	}
	scopes: {
		owned: [
			"shell-wrap/src/hookrail",
		]
		adjacent: [
			"shell-wrap/src/hookrail/src/lib",
			"shell-wrap/src/hookrail/src/cmd",
		]
		forbidden: [
			"cue registry",
			"evidence policy",
			"workflow DAG execution",
		]
	}

	discovery: {
		referencePaths: [
			"shell-wrap/AGENTS.md",
			"shell-wrap/src/hookrail/src/bashly.yml",
			"cue/patterns/domain/shell-wrap.cue",
		]
		startPoints: [
			"shell-wrap/src/hookrail/src/bashly.yml",
			"shell-wrap/src/hookrail/src/cmd",
		]
		suggestedLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/projections/codex-slice.cue",
			"shell-wrap/AGENTS.md",
		]
		forbiddenLoads: [
			"cue.mods/hookrail/*",
			"workflow execution",
			"eval generation",
		]
		staleSignals: [
			"shell-wrap work is being rediscovered from history instead of the card",
			"adapter changes are being inferred from runtime traces",
		]
	}

	knownGoodPatterns: [
		{
			id:      "cue-owns-schema-and-projection-authority"
			summary: "CUE owns schema and projection authority."
		},
		{
			id:      "shell-wrap-uses-thin-adapters"
			summary: "Shell-wrap exposes command surfaces through thin adapters."
		},
		{
			id:      "adjacent-proofs-remain-adjacent"
			summary: "Adjacent runner proofs remain adjacent, not pattern authority."
		},
	]

	knownFailures: [
		{
			id:        "schema-sprawl-without-a-card"
			symptom:   "The slice grows without a concrete card."
			avoidance: "Start from #EntityProjection and keep one concrete domain card."
		},
		{
			id:        "prompt-drift-from-cue"
			symptom:   "Hand-written prompt text drifts from CUE."
			avoidance: "Project from the card instead of duplicating prose."
		},
		{
			id:        "flow-runner-overreach"
			symptom:   "Extending the flow runner when the slice only needs pattern exposure."
			avoidance: "Keep the slice descriptive and avoid workflow execution."
		},
	]

	invariants: [
		{
			id:       "owns-shellwrap-command-surface"
			mustHold: "shell-wrap owns shell-wrapper/Bashly/Hookrail command-surface patterns."
		},
		{
			id:       "does-not-own-cue-registry"
			mustHold: "shell-wrap does not own CUE registry or evidence policy."
		},
		{
			id:       "descriptive-not-executing"
			mustHold: "The card is descriptive and does not introduce workflow DAG execution."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "cue-vet"
			requiredBefore: "review"
			proof:          "cue vet ./cue/patterns/... passes."
		},
		{
			id:             "shellwrap-card-export"
			requiredBefore: "gate"
			proof:          "The shell-wrap domain card exports successfully."
		},
		{
			id:             "codex-slice-export"
			requiredBefore: "eval"
			proof:          "The Codex slice projection exports successfully."
		},
		{
			id:             "projection-coverage"
			requiredBefore: "commit"
			proof:          "The projection includes surface, scopes, discovery, proofs, known good patterns, known failures, invariants, and gate promotion requirements."
		},
	]

	proofs: {
		commands: [
			"cue vet ./cue/patterns/...",
			"cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json",
		]
		artifacts: [
			"shell-wrap/AGENTS.md",
			"cue/patterns/domain/shell-wrap.cue",
			"cue/patterns/projections/codex-slice.cue",
		]
	}
}
