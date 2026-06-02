package projections

import "list"

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

import workflows "github.com/fatb4f/dotfiles/cue/patterns/workflows"

#CodexSlice: {
	schemaVersion: "cuerail.codexSlice.v1"
	selected:      domain.#DomainNodePattern
}

shellWrapSlice: #CodexSlice & {
	selected: domain.shellWrap
}

#WorkflowCodexSlice: {
	schemaVersion: "cuerail.codexWorkflowSlice.v1"

	_selected: workflows.#WorkflowPattern
	_involvedDomainCards: {
		sourceCode: domain.sourceCode
		shellWrap:  domain.shellWrap
		cue:        domain.cue
		git:        domain.git
	}

	_allKnownGoodPatterns: list.Concat([
		_selected.knownGoodPatterns,
		_involvedDomainCards.sourceCode.knownGoodPatterns,
		_involvedDomainCards.shellWrap.knownGoodPatterns,
		_involvedDomainCards.cue.knownGoodPatterns,
		_involvedDomainCards.git.knownGoodPatterns,
	])

	_allKnownFailures: list.Concat([
		_selected.knownFailures,
		_involvedDomainCards.sourceCode.knownFailures,
		_involvedDomainCards.shellWrap.knownFailures,
		_involvedDomainCards.cue.knownFailures,
		_involvedDomainCards.git.knownFailures,
	])

	_allInvariants: list.Concat([
		_selected.invariants,
		_involvedDomainCards.sourceCode.invariants,
		_involvedDomainCards.shellWrap.invariants,
		_involvedDomainCards.cue.invariants,
		_involvedDomainCards.git.invariants,
	])

	_allGatePromotionRequirements: list.Concat([
		_selected.gatePromotionRequirements,
		_involvedDomainCards.sourceCode.gatePromotionRequirements,
		_involvedDomainCards.shellWrap.gatePromotionRequirements,
		_involvedDomainCards.cue.gatePromotionRequirements,
		_involvedDomainCards.git.gatePromotionRequirements,
	])

	thisIsNow: {
		workflow: {
			id:        _selected.id
			domain:    _selected.domain
			summary:   _selected.summary
			lifecycle: _selected.lifecycle
		}
		cards: {
			sourceCode: {
				id:      _involvedDomainCards.sourceCode.id
				domain:  _involvedDomainCards.sourceCode.domain
				summary: _involvedDomainCards.sourceCode.surface.summary
				discovery: {
					authorityPaths: _involvedDomainCards.sourceCode.discovery.authorityPaths
					entrypoints:    _involvedDomainCards.sourceCode.discovery.entrypoints
				}
				proofs: {
					commands:  _involvedDomainCards.sourceCode.proofs.commands
					artifacts: _involvedDomainCards.sourceCode.proofs.artifacts
				}
			}
			shellWrap: {
				id:      _involvedDomainCards.shellWrap.id
				domain:  _involvedDomainCards.shellWrap.domain
				summary: _involvedDomainCards.shellWrap.surface.summary
				discovery: {
					authorityPaths: _involvedDomainCards.shellWrap.discovery.authorityPaths
					entrypoints:    _involvedDomainCards.shellWrap.discovery.entrypoints
				}
				proofs: {
					commands:  _involvedDomainCards.shellWrap.proofs.commands
					artifacts: _involvedDomainCards.shellWrap.proofs.artifacts
				}
			}
			cue: {
				id:      _involvedDomainCards.cue.id
				domain:  _involvedDomainCards.cue.domain
				summary: _involvedDomainCards.cue.surface.summary
				discovery: {
					authorityPaths: _involvedDomainCards.cue.discovery.authorityPaths
					entrypoints:    _involvedDomainCards.cue.discovery.entrypoints
				}
				proofs: {
					commands:  _involvedDomainCards.cue.proofs.commands
					artifacts: _involvedDomainCards.cue.proofs.artifacts
				}
			}
			git: {
				id:      _involvedDomainCards.git.id
				domain:  _involvedDomainCards.git.domain
				summary: _involvedDomainCards.git.surface.summary
				discovery: {
					authorityPaths: _involvedDomainCards.git.discovery.authorityPaths
					entrypoints:    _involvedDomainCards.git.discovery.entrypoints
				}
				proofs: {
					commands:  _involvedDomainCards.git.proofs.commands
					artifacts: _involvedDomainCards.git.proofs.artifacts
				}
			}
		}
	}

	thisIsHowWeWantIt: {
		workflow: {
			id:        _selected.id
			lifecycle: _selected.lifecycle
			cardIDs: [_involvedDomainCards.sourceCode.id, _involvedDomainCards.shellWrap.id, _involvedDomainCards.cue.id, _involvedDomainCards.git.id]
			cardDomains: [_involvedDomainCards.sourceCode.domain, _involvedDomainCards.shellWrap.domain, _involvedDomainCards.cue.domain, _involvedDomainCards.git.domain]
		}
		mustHold: _selected.invariants[0].mustHold
	}

	pathOfLeastResistance: [
		for edge in _selected.edges {
			"\(edge.from) -> \(edge.to): \(edge.summary)"
		},
		for requirement in _selected.gatePromotionRequirements {
			requirement.proof
		},
	]

	knownGoodPatterns:         _allKnownGoodPatterns
	knownFailures:             _allKnownFailures
	invariants:                _allInvariants
	gatePromotionRequirements: _allGatePromotionRequirements

	headsUp: [
		for failure in _allKnownFailures {
			"\(failure.id): \(failure.symptom)"
		},
		"Keep the slice limited to source-code, shell-wrap, cue, and git.",
	]
}

generatedCliChangeCodexSlice: #WorkflowCodexSlice & {
	_selected: workflows.generatedCliChange
}
