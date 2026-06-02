package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

import workflows "github.com/fatb4f/dotfiles/cue/patterns/workflows"

#CarryOverContract: {
	schemaVersion: "cuerail.carryOverContract.v1"

	selectedWorkflow:   string
	selectedProjection: string

	selectedDomainCards: {
		sourceCode: string
		shellWrap:  string
		cue:        string
		git:        string
	}

	requiredLoads:  [...string]
	forbiddenLoads: [...string]
	proofCommands:  [...string]

	resumeInstruction: string
}

generatedCliChangeCarryOver: #CarryOverContract & {
	selectedWorkflow:   workflows.generatedCliChange.id
	selectedProjection: "generatedCliChangeCodexSlice"

	selectedDomainCards: {
		sourceCode: domain.sourceCode.id
		shellWrap:  domain.shellWrap.id
		cue:        domain.cue.id
		git:        domain.git.id
	}

	requiredLoads: [
		"cue/patterns/domain/schema.cue",
		"cue/patterns/domain/source-code.cue",
		"cue/patterns/projections/workflow-slice.cue",
		"shell-wrap/AGENTS.md",
		"shell-wrap/src/hookrail/src/bashly.yml",
		"cue/patterns/domain/shell-wrap.cue",
		"cue/patterns/projections/codex-slice.cue",
		"cue/patterns/domain/cue.cue",
		"cue/patterns/workflows/schema.cue",
		"cue/patterns/domain/git.cue",
		"cue/patterns/workflows/generated-cli-change.cue",
	]

	forbiddenLoads: [
		"workflow execution",
		"eval generation",
		"materialized state",
		"cue registry",
		"evidence policy",
		"workflow DAG execution",
		"dotfile materialization",
	]

	proofCommands: [
		"cue vet ./cue/patterns/...",
		"cue export ./cue/patterns/projections -e generatedCliChangeCarryOver --out json",
		"cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json",
	]

	resumeInstruction: "Load the selected workflow, projection, and card handles; use required loads for context, avoid forbidden loads, and resume from CUE authorities instead of transcript history."
}
