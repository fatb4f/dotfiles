package domain

shellWrap: #DomainNodePattern & {
	id:     "shell-wrap"
	domain: "shell-wrap"

	surface: "shell-wrap/src/hookrail command-surface"
	scopes: [
		"shell-wrap/src/hookrail",
		"shell-wrap/src/hookrail/src/lib",
		"shell-wrap/src/hookrail/src/cmd",
	]

	knownGoodPatterns: [
		"CUE owns schema and projection authority.",
		"Shell-wrap exposes command surfaces through thin adapters.",
		"Adjacent runner proofs remain adjacent, not pattern authority.",
	]

	knownFailures: [
		"Schema sprawl without a concrete card.",
		"Hand-written prompt text that drifts from CUE.",
		"Extending the flow runner when the slice only needs pattern exposure.",
	]

	invariants: [
		"shell-wrap owns shell-wrapper/Bashly/Hookrail command-surface patterns.",
		"shell-wrap does not own CUE registry or evidence policy.",
		"The card is descriptive and does not introduce workflow DAG execution.",
	]

	gatePromotionRequirements: [
		"cue vet ./cue/patterns/... passes.",
		"The shell-wrap domain card exports successfully.",
		"The Codex slice projection exports successfully.",
		"The projection includes surface, scopes, known good patterns, known failures, invariants, and gate promotion requirements.",
	]
}
