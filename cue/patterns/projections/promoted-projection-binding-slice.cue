package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#PromotedProjectionBindingSlice: {
	schemaVersion: "cuerail.promotedProjectionBindingSlice.v1"

	sourceFacts: [string]: domain.#SourceFact

	fixtures: {
		good: {
			promotedProjection: domain.#PromotedProjection
			normalizedResponse: domain.#NormalizedRootResponse
		}
		fallback: {
			promotedProjection: domain.#PromotedProjection
			normalizedResponse: domain.#NormalizedRootResponse
		}
		bad: {
			keywordRelevance: {
				promotedProjection: domain.#PromotedProjection
				normalizedResponse: domain.#NormalizedRootResponse
			}
			missingRelationRef: {
				promotedProjection: domain.#PromotedProjection
				normalizedResponse: domain.#NormalizedRootResponse
			}
			rejectedRelation: {
				promotedProjection: domain.#PromotedProjection
				normalizedResponse: domain.#NormalizedRootResponse
			}
		}
	}
}

_goodPromotion:               cueFlowPromotionByUnificationSlice.proofs.good
_fallbackPromotion:           cueFlowPromotionByUnificationSlice.proofs.fallback
_keywordRelevancePromotion:   cueFlowPromotionByUnificationSlice.proofs.bad.keywordRelevance
_missingRelationRefPromotion: cueFlowPromotionByUnificationSlice.proofs.bad.missingRelationRef
_rejectedRelationPromotion:   cueFlowPromotionByUnificationSlice.proofs.bad.rejectedRelation

_selectedPatternProjection: domain.#PromotedProjection & {
	promotionOutcome:   _goodPromotion.outcome
	selectedPatternIDs: _goodPromotion.evidence.selectedPatternIDs
	exposedFiles:       _goodPromotion.evidence.loadedFiles
	projectedPrompt:    "Use only the accepted selected-pattern files and the cited authorization evidence when forming agent context."
	promptProjection:   projectedPrompt
	evidenceSummary: {
		selectedPatternIDs:  _goodPromotion.evidence.selectedPatternIDs
		exposedFiles:        _goodPromotion.evidence.loadedFiles
		authorizationSource: _goodPromotion.evidence.authorizationSource
		relationRefs:        _goodPromotion.evidence.relationRefs
		factRefs:            _goodPromotion.evidence.factRefs
		rationale:           _goodPromotion.evidence.rationale
	}
	contextProjection: {
		authorizationSource: _goodPromotion.evidence.authorizationSource
		rationale:           _goodPromotion.evidence.rationale
		relationRefs:        _goodPromotion.evidence.relationRefs
		factRefs:            _goodPromotion.evidence.factRefs
	}
	relationRefs: _goodPromotion.evidence.relationRefs
	factRefs:     _goodPromotion.evidence.factRefs
	rationale:    _goodPromotion.rationale
	evidenceRefs: _goodPromotion.factRefs
}

_fallbackProjection: domain.#PromotedProjection & {
	promotionOutcome:   _fallbackPromotion.outcome
	selectedPatternIDs: _fallbackPromotion.evidence.selectedPatternIDs
	exposedFiles:       _fallbackPromotion.evidence.loadedFiles
	projectedPrompt:    "Use only the bounded fallback files explicitly admitted by root-declared fallback evidence."
	promptProjection:   projectedPrompt
	evidenceSummary: {
		selectedPatternIDs:  _fallbackPromotion.evidence.selectedPatternIDs
		exposedFiles:        _fallbackPromotion.evidence.loadedFiles
		authorizationSource: "bounded-fallback"
		relationRefs:        _fallbackPromotion.evidence.relationRefs
		factRefs:            _fallbackPromotion.evidence.factRefs
		rationale:           _fallbackPromotion.evidence.rationale
	}
	contextProjection: {
		authorizationSource: "bounded-fallback"
		rationale:           _fallbackPromotion.evidence.rationale
		relationRefs:        _fallbackPromotion.evidence.relationRefs
		factRefs:            _fallbackPromotion.evidence.factRefs
	}
	relationRefs: _fallbackPromotion.evidence.relationRefs
	factRefs:     _fallbackPromotion.evidence.factRefs
	rationale:    _fallbackPromotion.rationale
	evidenceRefs: _fallbackPromotion.factRefs
}

_agentContextFor: {
	input: domain.#PromotedProjection & {
		promotionOutcome: {
			accepted: true
		}
	}
	output: domain.#AgentConsumableContext & {
		selectedPatternIDs: input.selectedPatternIDs
		exposedFiles:       input.exposedFiles
		projectedPrompt:    input.projectedPrompt
		promptProjection:   input.promptProjection
		evidenceSummary:    input.evidenceSummary
		relationRefs:       input.relationRefs
		factRefs:           input.factRefs
		rationale:          input.rationale
	}
}

_diagnosticProjection: {
	promotionOutcome: domain.#PromotionGateOutcome
	evidence:         domain.#AuthorizationEvidence
	factRefs:         domain.#FactRefList
}

_diagnosticsOnly: {
	input: _diagnosticProjection
	output: domain.#PromotedProjection & {
		promotionOutcome: input.promotionOutcome
		diagnostics: {
			status:              input.promotionOutcome.status
			classification:      *"diagnostic" | string
			violations:          input.promotionOutcome.violations
			missingRequirements: input.promotionOutcome.missingRequirements
			rationale:           input.promotionOutcome.rationale
			deniedLoads:         input.evidence.deniedLoads
			relationRefs:        input.evidence.relationRefs
			factRefs:            input.evidence.factRefs
		}
		evidenceRefs: input.factRefs
	}
}

_keywordRelevanceProjection: (_diagnosticsOnly & {
	input: {
		promotionOutcome: _keywordRelevancePromotion.outcome
		evidence:         _keywordRelevancePromotion.evidence
		factRefs:         _keywordRelevancePromotion.factRefs
	}
	output: diagnostics: classification: _keywordRelevancePromotion.outcome.classification
}).output

_missingRelationRefProjection: (_diagnosticsOnly & {
	input: {
		promotionOutcome: _missingRelationRefPromotion.outcome
		evidence:         _missingRelationRefPromotion.evidence
		factRefs:         _missingRelationRefPromotion.factRefs
	}
}).output

_rejectedRelationProjection: (_diagnosticsOnly & {
	input: {
		promotionOutcome: _rejectedRelationPromotion.outcome
		evidence:         _rejectedRelationPromotion.evidence
		factRefs:         _rejectedRelationPromotion.factRefs
	}
}).output

cueFlowPromotedProjectionBindingSlice: #PromotedProjectionBindingSlice & {
	sourceFacts: domain.sourceFacts

	fixtures: {
		good: {
			promotedProjection: _selectedPatternProjection
			normalizedResponse: domain.#NormalizedRootResponse & {
				requestID: "fixture.good.selected-pattern"
				promotion: _selectedPatternProjection
				consumable: {}
				agentContext: (_agentContextFor & {
					input: _selectedPatternProjection
				}).output
			}
		}
		fallback: {
			promotedProjection: _fallbackProjection
			normalizedResponse: domain.#NormalizedRootResponse & {
				requestID: "fixture.good.bounded-fallback"
				promotion: _fallbackProjection
				consumable: {}
				agentContext: (_agentContextFor & {
					input: _fallbackProjection
				}).output
			}
		}
		bad: {
			keywordRelevance: {
				promotedProjection: _keywordRelevanceProjection
				normalizedResponse: domain.#NormalizedRootResponse & {
					requestID: "fixture.bad.keyword-relevance"
					promotion: _keywordRelevanceProjection
					consumable: {}
					diagnostics: _keywordRelevanceProjection.diagnostics
				}
			}
			missingRelationRef: {
				promotedProjection: _missingRelationRefProjection
				normalizedResponse: domain.#NormalizedRootResponse & {
					requestID: "fixture.bad.missing-relation-ref"
					promotion: _missingRelationRefProjection
					consumable: {}
					diagnostics: _missingRelationRefProjection.diagnostics
				}
			}
			rejectedRelation: {
				promotedProjection: _rejectedRelationProjection
				normalizedResponse: domain.#NormalizedRootResponse & {
					requestID: "fixture.bad.rejected-relation"
					promotion: _rejectedRelationProjection
					consumable: {}
					diagnostics: _rejectedRelationProjection.diagnostics
				}
			}
		}
	}
}
