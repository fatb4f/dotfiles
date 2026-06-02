package runs

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"
import lifecycle "github.com/fatb4f/dotfiles/cue/patterns/lifecycle"
import workflows "github.com/fatb4f/dotfiles/cue/patterns/workflows"

generatedCliCarryOverE6ee888: lifecycle.#ProcessLifecycleProof & {
	schemaVersion: "cuerail.processLifecycleProof.v1"

	slice: {
		id:        "generated-cli-carry-over-e6ee888"
		objective: "collect repeatable lifecycle data"
	}

	session: {
		id: "e6ee888"
	}

	git: {
		commit:    "e6ee888333141a27f455a284c5dbd892b03a1d9f"
		dirtyState: "clean"
	}

	selection: {
		workflow:   workflows.generatedCliChange.id
		projection: "generatedCliChangeCodexSlice"
		carryOver:  "generatedCliChangeCarryOver"

		domainCards: [
			domain.sourceCode.id,
			domain.shellWrap.id,
			domain.cue.id,
			domain.git.id,
		]
	}

	route: {
		firstContactGuardFollowed: true

		requiredLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/source-code.cue",
			"cue/patterns/domain/shell-wrap.cue",
			"cue/patterns/domain/cue.cue",
			"cue/patterns/domain/git.cue",
			"cue/patterns/projections/codex-slice.cue",
			"cue/patterns/projections/carry-over.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]

		loadedPaths: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/source-code.cue",
			"cue/patterns/domain/shell-wrap.cue",
			"cue/patterns/domain/cue.cue",
			"cue/patterns/domain/git.cue",
			"cue/patterns/projections/codex-slice.cue",
			"cue/patterns/projections/carry-over.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]

		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"materialized state",
			"cue.mods/hookrail/*",
			"dotfile materialization",
			"shell adapter implementation",
		]

		forbiddenLoadViolations: []
	}

	change: {
		filesChanged: [
			"cue/patterns/projections/carry-over.cue",
		]
		scope: "cue/patterns/projections"
	}

	validate: {
		commands: [
			{
				cmd:    "cue vet ./cue/patterns/..."
				status: "pass"
				summary: "The pattern graph validated."
			},
			{
				cmd:    "cue export ./cue/patterns/projections -e generatedCliChangeCarryOverLifecycleProof --out json"
				status: "pass"
				summary: "The lifecycle proof exported."
			},
			{
				cmd:    "cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json"
				status: "pass"
				summary: "The Codex slice exported."
			},
		]
	}

	closeout: {
		status: "committed"
	}

	tokenUsage: {
		available: false
		status:    "unavailable"
		degraded:  true

		notes: [
			"no token usage artifact was captured for this run",
		]
	}

	notes: [
		"No detours recorded.",
		"Future token evidence capture: cuerail-token-usage --from-file <session-or-run-log> --run-id <id> --commit <sha> --source-kind codex-session-artifact --output <path>",
	]
}
