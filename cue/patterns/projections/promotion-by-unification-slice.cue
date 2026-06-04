package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#PromotionByUnificationSlice: {
	schemaVersion: "cueflow.promotionByUnificationSlice.v1"

	sourceFacts: [string]: domain.#SourceFact

	rootInvariantVocabulary: [...domain.#GateInvariant]

	selectedGateCases: {
		normal:     domain.#PromotionGateCase
		fallback:   domain.#PromotionGateCase
		drift:      domain.#PromotionGateCase
		incomplete: domain.#PromotionGateCase
		rejected:   domain.#PromotionGateCase
	}

	patternFragment: domain.#PatternPromotionFragment

	proofs: {
		good:     domain.#PromotionGate
		fallback: domain.#PromotionGate
		bad: {
			keywordRelevance:                domain.#PromotionGate
			goOwnedPolicy:                   domain.#PromotionGate
			missingRelationRef:              domain.#PromotionGate
			missingFactRefs:                 domain.#PromotionGate
			rejectedRelation:                domain.#PromotionGate
			unknownAuthorizationSource:      domain.#PromotionGate
			fallbackOutsideBounds:           domain.#PromotionGate
			requirementWithoutKnownFactRefs: domain.#PromotionGate
			patternRedefinesGateShape:       domain.#PromotionGate
			fixtureAttemptsAccepted:         domain.#PromotionGate
		}
	}
}

_promotionInvariants: [
	{
		id:       "keyword-relevance-is-not-load-authorization"
		mustHold: "Keyword relevance may explain why a file looked interesting, but it is not a load authorization relation."
		factRefs: [
			"root.file_loads_require_authorization_relation",
			"review.freeze_gate_rejects_relevance_only_loads",
		]
	},
	{
		id:       "go-adapter-does-not-own-policy"
		mustHold: "Go may emit evidence from root-declared contracts, but hidden Go policy must not authorize promotion."
		factRefs: [
			"root.authorization_evidence_is_root_owned",
			"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
		]
	},
	{
		id:       "selected-pattern-files-require-authorization-evidence"
		mustHold: "Loaded selected-pattern files must carry authorizedBy, relationRef, factRefs, and reason."
		factRefs: [
			"root.authorization_evidence_is_root_owned",
			"root.file_loads_require_authorization_relation",
		]
	},
	{
		id:       "bounded-fallback-limits-loads-to-root-declared-surfaces"
		mustHold: "Fallback loads are limited to explicit AGENTS.cue, index, or root-declared surfaces."
		factRefs: [
			"root.bounded_fallback_limits_loads_to_declared_surfaces",
			"root.file_loads_require_authorization_relation",
		]
	},
	{
		id:       "promotion-relations-require-known-factrefs"
		mustHold: "Every relation edge used by promotion must carry root-known factRefs."
		factRefs: [
			"root.relations_are_admitted_only_when_backed_by_facts",
			"root.rejected_relations_do_not_satisfy_promotion",
		]
	},
	{
		id:       "promotion-requirements-require-known-factrefs"
		mustHold: "Every requirement used by promotion must carry root-known factRefs."
		factRefs: [
			"root.relations_are_admitted_only_when_backed_by_facts",
			"root.task_patterns_provide_promotion_fragments",
		]
	},
	{
		id:       "accepted-is-derived-not-fixture-authored"
		mustHold: "Accepted is projected from the unified promotion outcome, not supplied as fixture input."
		factRefs: [
			"root.promotion_gate_outcome_is_derived",
			"fixture.promotion_by_unification_slice_exports",
		]
	},
]

_normalCase: domain.#PromotionGateCase & {
	id:                  "normal-promotion"
	status:              "accepted"
	authorizationSource: "selected-pattern"
	allowedRelationRefs: [
		"rel.selected-pattern-authorizes-loaded-file",
		"rel.root-policy-authorizes-loaded-file",
	]
	requiredInvariantRefs: [
		"keyword-relevance-is-not-load-authorization",
		"go-adapter-does-not-own-policy",
		"selected-pattern-files-require-authorization-evidence",
		"promotion-relations-require-known-factrefs",
		"promotion-requirements-require-known-factrefs",
		"accepted-is-derived-not-fixture-authored",
	]
	requiredFactRefs: [
		"root.promotion_gate_contract_is_root_owned",
		"root.promotion_gate_outcome_is_derived",
		"root.task_patterns_provide_promotion_fragments",
		"root.rejected_relations_do_not_satisfy_promotion",
	]
	rationale: "Normal promotion is accepted only when selected-pattern evidence, allowed authorization relations, root invariants, and known facts unify."
}

_fallbackCase: domain.#PromotionGateCase & {
	id:                  "bounded-fallback-promotion"
	status:              "accepted"
	authorizationSource: "bounded-fallback"
	allowedRelationRefs: [
		"rel.bounded-fallback-authorizes-root-declared-surface",
	]
	requiredInvariantRefs: [
		"bounded-fallback-limits-loads-to-root-declared-surfaces",
		"promotion-relations-require-known-factrefs",
		"promotion-requirements-require-known-factrefs",
		"accepted-is-derived-not-fixture-authored",
	]
	requiredFactRefs: [
		"root.bounded_fallback_limits_loads_to_declared_surfaces",
		"root.file_loads_require_authorization_relation",
		"root.promotion_gate_outcome_is_derived",
	]
	rationale: "Bounded fallback promotion is accepted only for explicit root-declared surfaces with allowed relation and fact evidence."
}

_driftCase: domain.#PromotionGateCase & {
	id:                  "rejected-drift"
	status:              "drift"
	authorizationSource: "rejected-drift"
	allowedRelationRefs: [
		"rel.root-policy-authorizes-loaded-file",
	]
	requiredInvariantRefs: [
		"keyword-relevance-is-not-load-authorization",
		"go-adapter-does-not-own-policy",
		"accepted-is-derived-not-fixture-authored",
	]
	requiredFactRefs: [
		"root.promotion_gate_outcome_is_derived",
		"review.freeze_gate_rejects_relevance_only_loads",
	]
	rationale: "Architectural violations are exported as drift evidence; they do not satisfy accepted promotion."
}

_incompleteCase: domain.#PromotionGateCase & {
	id:                  "incomplete-evidence"
	status:              "incomplete"
	authorizationSource: "rejected-drift"
	allowedRelationRefs: [
		"rel.root-policy-authorizes-loaded-file",
	]
	requiredInvariantRefs: [
		"selected-pattern-files-require-authorization-evidence",
		"promotion-requirements-require-known-factrefs",
	]
	requiredFactRefs: [
		"root.file_loads_require_authorization_relation",
		"root.promotion_gate_outcome_is_derived",
	]
	rationale: "Incomplete evidence remains inspectable but cannot promote."
}

_rejectedCase: domain.#PromotionGateCase & {
	id:                  "invalid-relation"
	status:              "rejected"
	authorizationSource: "rejected-drift"
	allowedRelationRefs: [
		"rel.root-policy-authorizes-loaded-file",
	]
	requiredInvariantRefs: [
		"promotion-relations-require-known-factrefs",
		"accepted-is-derived-not-fixture-authored",
	]
	requiredFactRefs: [
		"root.rejected_relations_do_not_satisfy_promotion",
		"root.promotion_gate_outcome_is_derived",
	]
	rationale: "Rejected relation evidence cannot satisfy allowed promotion relation requirements."
}

_patternFragment: domain.#PatternPromotionFragment & {
	id:        "fragment.selected-pattern-promotion"
	patternID: "selected-pattern-contract"
	requires: [
		{
			id:          "req.selected-patterns-recorded"
			description: "Selected pattern IDs must be present before promotion."
			requires: [
				"evidence.selectedPatternIDs",
			]
			factRefs: [
				"root.task_patterns_provide_promotion_fragments",
			]
		},
		{
			id:          "req.loaded-files-authorized"
			description: "Loaded files must carry authorizedBy, relationRef, known factRefs, and reason."
			requires: [
				"loadedFiles.authorizedBy",
				"loadedFiles.relationRef",
				"loadedFiles.factRefs",
				"loadedFiles.reason",
			]
			factRefs: [
				"root.authorization_evidence_is_root_owned",
				"root.file_loads_require_authorization_relation",
			]
		},
		{
			id:          "req.denied-loads-explain-rejections"
			description: "Denied loads explain rejected paths and rejected authorization relations."
			requires: [
				"deniedLoads.rejectedRelationRef",
				"deniedLoads.reason",
			]
			factRefs: [
				"review.freeze_gate_rejects_relevance_only_loads",
				"root.rejected_relations_do_not_satisfy_promotion",
			]
		},
	]
	invariantRefs: [
		"keyword-relevance-is-not-load-authorization",
		"go-adapter-does-not-own-policy",
		"selected-pattern-files-require-authorization-evidence",
		"promotion-relations-require-known-factrefs",
		"promotion-requirements-require-known-factrefs",
		"accepted-is-derived-not-fixture-authored",
	]
	allowedRelationRefs: [
		"rel.selected-pattern-authorizes-loaded-file",
		"rel.root-policy-authorizes-loaded-file",
	]
	evidenceExpectations: [
		"selectedPatternIDs present",
		"loadedFiles authorized by root-owned source",
		"loadedFiles carry relationRef, factRefs, and reason",
		"deniedLoads explain rejected paths",
		"go adapter is adapter/emitter/enforcer only",
		"keyword relevance alone does not authorize loading",
	]
	factRefs: [
		"root.promotion_gate_contract_is_root_owned",
		"root.task_patterns_provide_promotion_fragments",
		"root.file_loads_require_authorization_relation",
	]
	rationale: "The selected pattern contributes only promotion requirements, invariant refs, relation expectations, and evidence expectations."
}

_fallbackFragment: domain.#PatternPromotionFragment & {
	id:        "fragment.bounded-fallback-promotion"
	patternID: "bounded-fallback"
	requires: [
		{
			id:          "req.fallback-root-declared-surfaces"
			description: "Fallback files must be limited to explicit AGENTS.cue, index, or root-declared surfaces."
			requires: [
				"authorizationSource.bounded-fallback",
				"loadedFiles.relationRef",
				"loadedFiles.factRefs",
			]
			factRefs: [
				"root.bounded_fallback_limits_loads_to_declared_surfaces",
				"root.file_loads_require_authorization_relation",
			]
		},
	]
	invariantRefs: [
		"bounded-fallback-limits-loads-to-root-declared-surfaces",
		"promotion-relations-require-known-factrefs",
		"promotion-requirements-require-known-factrefs",
		"accepted-is-derived-not-fixture-authored",
	]
	allowedRelationRefs: [
		"rel.bounded-fallback-authorizes-root-declared-surface",
	]
	evidenceExpectations: [
		"authorizationSource is bounded-fallback",
		"fallback files are root-declared surfaces",
		"fallback evidence carries relationRefs and factRefs",
		"fallback outside bounded surfaces does not promote",
	]
	factRefs: [
		"root.bounded_fallback_limits_loads_to_declared_surfaces",
		"root.file_loads_require_authorization_relation",
		"root.task_patterns_provide_promotion_fragments",
	]
	rationale: "The fallback pattern contributes only bounded fallback requirements, invariant refs, relation expectations, and evidence expectations."
}

_goodPromotionGate: domain.#PromotionGate & {
	id:         "promotion.good.selected-pattern"
	patternID:  _patternFragment.patternID
	case:       _normalCase
	fragment:   _patternFragment
	requires:   _patternFragment.requires
	invariants: _promotionInvariants
	evidence:   cueFlowAuthorizationEvidenceSlice.good
	relations: [
		cueFlowFactRootedRelationSlice.relationEdges[10],
	]
	factRefs: [
		"root.promotion_gate_contract_is_root_owned",
		"root.promotion_gate_outcome_is_derived",
		"root.task_patterns_provide_promotion_fragments",
		"root.rejected_relations_do_not_satisfy_promotion",
		"fixture.typed_authorization_evidence_slice_exports",
		"fixture.fact_rooted_cue_flow_relation_slice_exports",
	]
	outcome: {
		rationale: "Selected-pattern authorization evidence, allowed relation facts, root invariants, and the pattern fragment unify to accepted normal form."
	}
	rationale: "Replayable proof: root gate & normal case & selected-pattern fragment & invariants & good evidence & allowed relations & known facts."
}

_fallbackPromotionGate: domain.#PromotionGate & {
	id:         "promotion.good.bounded-fallback"
	patternID:  "bounded-fallback"
	case:       _fallbackCase
	fragment:   _fallbackFragment
	requires:   fragment.requires
	invariants: _promotionInvariants
	evidence:   cueFlowAuthorizationEvidenceSlice.fallback
	relations: [
		cueFlowFactRootedRelationSlice.relationEdges[11],
	]
	factRefs: [
		"root.bounded_fallback_limits_loads_to_declared_surfaces",
		"root.file_loads_require_authorization_relation",
		"root.promotion_gate_outcome_is_derived",
		"fixture.typed_authorization_evidence_slice_exports",
	]
	outcome: {
		rationale: "Fallback evidence is bounded to explicit root-declared surfaces and still carries allowed relationRefs and known factRefs."
	}
	rationale: "Replayable proof: root gate & bounded fallback case & fallback fragment & invariants & fallback evidence & allowed fallback relation & known facts."
}

_driftPromotionGate: domain.#PromotionGate & {
	id:         string
	patternID:  _patternFragment.patternID
	case:       _driftCase
	fragment:   _patternFragment
	requires:   _patternFragment.requires
	invariants: _promotionInvariants
	evidence:   cueFlowAuthorizationEvidenceSlice.bad
	relations: [
		cueFlowFactRootedRelationSlice.relationEdges[9],
	]
	factRefs: [
		"root.promotion_gate_outcome_is_derived",
		"review.freeze_gate_rejects_relevance_only_loads",
	]
	outcome: {
		classification: "architectural-drift"
		violations: [...string]
		missingRequirements: []
		rationale: string
	}
	rationale: "Replayable drift proof: rejected evidence unifies with a drift case, not an accepted case."
}

_incompletePromotionGate: domain.#PromotionGate & {
	id:         string
	patternID:  _patternFragment.patternID
	case:       _incompleteCase
	fragment:   _patternFragment
	requires:   _patternFragment.requires
	invariants: _promotionInvariants
	evidence:   cueFlowAuthorizationEvidenceSlice.bad
	relations: [
		cueFlowFactRootedRelationSlice.relationEdges[9],
	]
	factRefs: [
		"root.file_loads_require_authorization_relation",
		"root.promotion_gate_outcome_is_derived",
	]
	outcome: {
		violations: [...string]
		missingRequirements: [...string]
		rationale: string
	}
	rationale: "Replayable incomplete proof: missing evidence stays inspectable and cannot promote."
}

_rejectedPromotionGate: domain.#PromotionGate & {
	id:         string
	patternID:  _patternFragment.patternID
	case:       _rejectedCase
	fragment:   _patternFragment
	requires:   _patternFragment.requires
	invariants: _promotionInvariants
	evidence:   cueFlowAuthorizationEvidenceSlice.bad
	relations: [
		cueFlowFactRootedRelationSlice.relationEdges[9],
	]
	rejectedRelations: [
		cueFlowFactRootedRelationSlice.relationEdges[13],
		cueFlowFactRootedRelationSlice.relationEdges[14],
	]
	factRefs: [
		"root.rejected_relations_do_not_satisfy_promotion",
		"root.promotion_gate_outcome_is_derived",
	]
	outcome: {
		violations: [...string]
		missingRequirements: []
		rationale: string
	}
	rationale: "Replayable rejected proof: invalid relation conditions cannot promote."
}

cueFlowPromotionByUnificationSlice: #PromotionByUnificationSlice & {
	sourceFacts: domain.sourceFacts

	rootInvariantVocabulary: _promotionInvariants

	selectedGateCases: {
		normal:     _normalCase
		fallback:   _fallbackCase
		drift:      _driftCase
		incomplete: _incompleteCase
		rejected:   _rejectedCase
	}

	patternFragment: _patternFragment

	proofs: {
		good:     _goodPromotionGate
		fallback: _fallbackPromotionGate
		bad: {
			keywordRelevance: _driftPromotionGate & {
				id: "promotion.bad.keyword-relevance"
				outcome: {
					violations: [
						"keyword relevance alone attempted to authorize a loaded file",
					]
					rationale: "Keyword relevance is exported as drift evidence and cannot satisfy an allowed authorization relation."
				}
			}
			goOwnedPolicy: _driftPromotionGate & {
				id: "promotion.bad.go-owned-policy"
				outcome: {
					violations: [
						"go adapter attempted to own hidden load authorization",
					]
					rationale: "Go-owned hidden authorization is drift; Go remains adapter/emitter/enforcer only."
				}
			}
			missingRelationRef: _incompletePromotionGate & {
				id: "promotion.bad.missing-relation-ref"
				outcome: {
					violations: [
						"loaded file evidence is missing an admissible relationRef",
					]
					missingRequirements: [
						"loadedFiles.relationRef",
					]
					rationale: "The evidence is structurally inspectable as incomplete, but cannot promote."
				}
			}
			missingFactRefs: _incompletePromotionGate & {
				id: "promotion.bad.missing-factrefs"
				outcome: {
					violations: [
						"loaded file evidence is missing known factRefs",
					]
					missingRequirements: [
						"loadedFiles.factRefs",
					]
					rationale: "Fact references must inhabit the root-owned known fact ID space."
				}
			}
			rejectedRelation: _rejectedPromotionGate & {
				id: "promotion.bad.rejected-relation"
				outcome: {
					violations: [
						"relation edge exists but allowed is false",
					]
					rationale: "Rejected relations can be exported as evidence but cannot satisfy allowed promotion relations."
				}
			}
			unknownAuthorizationSource: _driftPromotionGate & {
				id: "promotion.bad.unknown-authorization-source"
				outcome: {
					violations: [
						"authorization source is outside the root-owned authorization source vocabulary",
					]
					rationale: "Unknown authorization sources are rejected by type membership before they can promote."
				}
			}
			fallbackOutsideBounds: _driftPromotionGate & {
				id: "promotion.bad.fallback-outside-bounds"
				outcome: {
					violations: [
						"fallback attempted to load outside explicit AGENTS.cue, index, or root-declared surfaces",
					]
					rationale: "Fallback remains bounded to root-declared surfaces."
				}
			}
			requirementWithoutKnownFactRefs: _incompletePromotionGate & {
				id: "promotion.bad.requirement-without-known-factrefs"
				outcome: {
					violations: [
						"promotion requirement did not carry known factRefs",
					]
					missingRequirements: [
						"requires.factRefs",
					]
					rationale: "Promotion requirements are typed by the root-owned fact ID space."
				}
			}
			patternRedefinesGateShape: _driftPromotionGate & {
				id: "promotion.bad.pattern-redefines-gate-shape"
				outcome: {
					violations: [
						"task pattern attempted to define promotion gate shape instead of providing a fragment",
					]
					rationale: "The root schema owns #PromotionGate; patterns provide thin fragments only."
				}
			}
			fixtureAttemptsAccepted: _driftPromotionGate & {
				id: "promotion.bad.fixture-attempts-accepted"
				attemptedOutcome: {
					status:   "accepted"
					accepted: true
				}
				outcome: {
					violations: [
						"fixture attempted to self-declare accepted without satisfying accepted gate constraints",
					]
					rationale: "Accepted is derived from status/case unification, so this fixture remains drift with accepted false."
				}
			}
		}
	}
}
