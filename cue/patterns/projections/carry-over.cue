package projections

import "list"

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

import workflows "github.com/fatb4f/dotfiles/cue/patterns/workflows"

#CarryOverContract: {
	schemaVersion: "cueflow.carryOverContract.v1"

	selectedWorkflow:   string
	selectedProjection: string

	selectedDomainCards: {
		sourceCode: string
		shellWrap:  string
		cue:        string
		git:        string
	}

	requiredLoads: [...string]
	forbiddenLoads: [...string]
	proofCommands: [...string]

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

	_selectedDomainCards: {
		sourceCode: domain.sourceCode
		shellWrap:  domain.shellWrap
		cue:        domain.cue
		git:        domain.git
	}

	requiredLoads: list.Concat([
		_selectedDomainCards.sourceCode.discovery.requiredLoads,
		_selectedDomainCards.shellWrap.discovery.requiredLoads,
		_selectedDomainCards.cue.discovery.requiredLoads,
		_selectedDomainCards.git.discovery.requiredLoads,
	])

	forbiddenLoads: list.Concat([
		_selectedDomainCards.sourceCode.discovery.forbiddenLoads,
		_selectedDomainCards.shellWrap.discovery.forbiddenLoads,
		_selectedDomainCards.cue.discovery.forbiddenLoads,
		_selectedDomainCards.git.discovery.forbiddenLoads,
	])

	proofCommands: list.Concat([
		_selectedDomainCards.sourceCode.proofs.commands,
		_selectedDomainCards.shellWrap.proofs.commands,
		_selectedDomainCards.cue.proofs.commands,
		_selectedDomainCards.git.proofs.commands,
		[
			"cue export ./cue/patterns/projections -e generatedCliChangeCarryOver --out json",
		],
	])

	resumeInstruction: "Load the selected workflow, projection, and card handles; use required loads for context, avoid forbidden loads, and resume from CUE authorities instead of transcript history."
}
