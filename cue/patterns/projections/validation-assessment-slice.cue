package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

_reviewPath: "docs/architecture/agentnode-green-light-review.md"
_tracePath:  "var/run/hookrail/flow-trace.latest.json"

_observedFacts: domain.#ObservedFactSet & {
	factIDs: [
		"review.green_light_review_exists",
		"runtime.flow_trace_exists",
		"review.accepted_exposed_file_count",
		"review.rejected_exposed_file_count",
		"review.rejected_denied_load_count",
		"review.broad_surface_bytes",
		"review.broad_surface_lines",
		"review.broad_surface_files",
		"review.projected_surface_bytes",
		"review.projected_surface_lines",
		"review.projected_surface_files",
		"review.reduction_bytes_percent",
		"review.reduction_lines_percent",
		"review.reduction_files_percent",
		"root.schema_owns_validation_contract_shape",
		"scheme.fragments_conform_to_root_contracts",
		"task_patterns_provide_fragments_not_authority_roots",
		"promotion.outcome_derived_by_cue_unification",
		"normalized_response_is_adapter_boundary",
		"adapter.does_not_bypass_promotion_root_authority",
		"promotion.good_selected_pattern_accepted",
		"promotion.bounded_fallback_accepted",
		"promotion.keyword_relevance_not_authorized",
		"promotion.missing_relation_ref_not_accepted",
		"promotion.rejected_relation_not_allowed",
		"promotion.bad_cases_not_accepted",
		"accepted_response_exposes_agent_context",
		"nonaccepted_response_exposes_diagnostics_only",
		"nonaccepted_response_rejects_agent_context",
		"adapter.branches_on_consumable",
		"adapter.consumes_normalized_response_fields",
		"adapter.does_not_consume_promotion_internals",
		"adapter.action_classification",
		"adapter.not_policy_source",
		"estimator.method_is_rough_not_tokenizer_exact",
	]
	rationale: "Observed facts are inputs from the current green-light review, runtime trace, and CUE projection fixtures; acceptance is derived by unifying them with root-owned validation gates."
	facts: {
		"review.green_light_review_exists": {
			id:        "review.green_light_review_exists"
			source:    _reviewPath
			claim:     "The AgentNode green-light review exists."
			value:     true
			rationale: "The review document is the local review evidence source for this validation slice."
		}
		"runtime.flow_trace_exists": {
			id:        "runtime.flow_trace_exists"
			source:    _tracePath
			claim:     "The latest Hookrail flow trace exists."
			value:     true
			rationale: "The trace artifact records normalized adapter consumption and rough context metrics."
		}
		"review.accepted_exposed_file_count": {
			id:        "review.accepted_exposed_file_count"
			source:    _reviewPath
			claim:     "The accepted runtime path exposed three files."
			value:     3
			rationale: "Accepted exposure remains limited to selected-pattern authorized files."
		}
		"review.rejected_exposed_file_count": {
			id:        "review.rejected_exposed_file_count"
			source:    _reviewPath
			claim:     "The rejected runtime path exposed zero files."
			value:     0
			rationale: "Rejected promotion does not expose agent context files."
		}
		"review.rejected_denied_load_count": {
			id:        "review.rejected_denied_load_count"
			source:    _reviewPath
			claim:     "The rejected runtime path recorded two denied loads."
			value:     2
			rationale: "Denied loads remain diagnostic evidence instead of context exposure."
		}
		"review.broad_surface_bytes": {
			id:        "review.broad_surface_bytes"
			source:    _reviewPath
			claim:     "Broad input surface was 87,137 bytes."
			value:     87137
			rationale: "Rough broad-surface byte count from the review and trace."
		}
		"review.broad_surface_lines": {
			id:        "review.broad_surface_lines"
			source:    _reviewPath
			claim:     "Broad input surface was 2,618 lines."
			value:     2618
			rationale: "Rough broad-surface line count from the review and trace."
		}
		"review.broad_surface_files": {
			id:        "review.broad_surface_files"
			source:    _reviewPath
			claim:     "Broad input surface was 10 files."
			value:     10
			rationale: "Rough broad-surface file count from the review and trace."
		}
		"review.projected_surface_bytes": {
			id:        "review.projected_surface_bytes"
			source:    _reviewPath
			claim:     "Accepted projected context was 34,229 bytes."
			value:     34229
			rationale: "Rough projected byte count from accepted context."
		}
		"review.projected_surface_lines": {
			id:        "review.projected_surface_lines"
			source:    _reviewPath
			claim:     "Accepted projected context was 1,026 lines."
			value:     1026
			rationale: "Rough projected line count from accepted context."
		}
		"review.projected_surface_files": {
			id:        "review.projected_surface_files"
			source:    _reviewPath
			claim:     "Accepted projected context was 3 files."
			value:     3
			rationale: "Rough projected file count from accepted context."
		}
		"review.reduction_bytes_percent": {
			id:        "review.reduction_bytes_percent"
			source:    _reviewPath
			claim:     "Accepted byte reduction was 60.7%."
			value:     60.7
			rationale: "The recorded byte reduction is material for this rough estimator slice."
		}
		"review.reduction_lines_percent": {
			id:        "review.reduction_lines_percent"
			source:    _reviewPath
			claim:     "Accepted line reduction was 60.8%."
			value:     60.8
			rationale: "The recorded line reduction is material for this rough estimator slice."
		}
		"review.reduction_files_percent": {
			id:        "review.reduction_files_percent"
			source:    _reviewPath
			claim:     "Accepted file-count reduction was 70.0%."
			value:     70.0
			rationale: "The recorded file-count reduction is material for this rough estimator slice."
		}
		"root.schema_owns_validation_contract_shape": {
			id:        "root.schema_owns_validation_contract_shape"
			source:    "cue/patterns/domain/schema.cue"
			claim:     "The root schema owns #RootValidationContract, #ValidationGate, #ValidationRequirement, #ValidationGateOutcome, #ObservedFact, #ObservedFactSet, and #ValidationAssessment."
			value:     true
			rationale: "Validation shape is defined in the root domain schema rather than in Go or a local fixture type."
		}
		"scheme.fragments_conform_to_root_contracts": {
			id:        "scheme.fragments_conform_to_root_contracts"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Promotion scheme fragments unify with root-owned gate contracts."
			value:     true
			rationale: "Existing promotion fragments are typed as domain.#PatternPromotionFragment and gates as domain.#PromotionGate."
		}
		"task_patterns_provide_fragments_not_authority_roots": {
			id:        "task_patterns_provide_fragments_not_authority_roots"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Task patterns provide fragments and do not redefine authority roots."
			value:     true
			rationale: "Pattern fragments carry requirements, invariant refs, allowed relation refs, and evidence expectations."
		}
		"promotion.outcome_derived_by_cue_unification": {
			id:        "promotion.outcome_derived_by_cue_unification"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Promotion outcome is derived by CUE unification."
			value:     true
			rationale: "The promotion slice unifies root gate, case, fragment, invariants, evidence, relations, and facts."
		}
		"normalized_response_is_adapter_boundary": {
			id:        "normalized_response_is_adapter_boundary"
			source:    "cue/patterns/domain/schema.cue"
			claim:     "Normalized root response is the adapter boundary."
			value:     true
			rationale: "The root response exposes consumable accepted/status plus either agentContext or diagnostics."
		}
		"adapter.does_not_bypass_promotion_root_authority": {
			id:        "adapter.does_not_bypass_promotion_root_authority"
			source:    _tracePath
			claim:     "The adapter does not bypass promotion or root authority for exposure decisions."
			value:     true
			rationale: "The runtime trace records normalized consumable state and root-shaped evidence."
		}
		"promotion.good_selected_pattern_accepted": {
			id:        "promotion.good_selected_pattern_accepted"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "The accepted selected-pattern promotion fixture has accepted outcome."
			value:     cueFlowPromotionByUnificationSlice.proofs.good.outcome.accepted
			rationale: "This is derived from the existing promotion-by-unification projection."
		}
		"promotion.bounded_fallback_accepted": {
			id:        "promotion.bounded_fallback_accepted"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "The bounded fallback promotion fixture has accepted outcome."
			value:     cueFlowPromotionByUnificationSlice.proofs.fallback.outcome.accepted
			rationale: "This is derived from the existing bounded fallback promotion gate."
		}
		"promotion.keyword_relevance_not_authorized": {
			id:        "promotion.keyword_relevance_not_authorized"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Keyword relevance alone does not authorize loading."
			value:     cueFlowPromotionByUnificationSlice.proofs.bad.keywordRelevance.outcome.accepted
			rationale: "The bad keyword-relevance fixture is drift with accepted false."
		}
		"promotion.missing_relation_ref_not_accepted": {
			id:        "promotion.missing_relation_ref_not_accepted"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Missing relationRef does not produce accepted promotion."
			value:     cueFlowPromotionByUnificationSlice.proofs.bad.missingRelationRef.outcome.accepted
			rationale: "The missing relationRef fixture is incomplete with accepted false."
		}
		"promotion.rejected_relation_not_allowed": {
			id:        "promotion.rejected_relation_not_allowed"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Rejected relations do not satisfy allowed relation requirements."
			value:     cueFlowPromotionByUnificationSlice.proofs.bad.rejectedRelation.outcome.accepted
			rationale: "The rejected relation fixture is rejected with accepted false."
		}
		"promotion.bad_cases_not_accepted": {
			id:        "promotion.bad_cases_not_accepted"
			source:    "cue/patterns/projections/promotion-by-unification-slice.cue"
			claim:     "Bad promotion cases produce accepted false with drift, rejected, or incomplete status."
			value:     true
			rationale: "Keyword relevance is drift, missing relationRef is incomplete, rejected relation is rejected, and fixture-attempted accepted remains drift."
		}
		"accepted_response_exposes_agent_context": {
			id:        "accepted_response_exposes_agent_context"
			source:    "cue/patterns/projections/promoted-projection-binding-slice.cue"
			claim:     "Accepted normalized response exposes agentContext."
			value:     cueFlowPromotedProjectionBindingSlice.fixtures.good.normalizedResponse.agentContext.exposedFiles[0].path
			rationale: "The accepted normalized response can only export this path if agentContext exists."
		}
		"nonaccepted_response_exposes_diagnostics_only": {
			id:        "nonaccepted_response_exposes_diagnostics_only"
			source:    "cue/patterns/projections/promoted-projection-binding-slice.cue"
			claim:     "Non-accepted normalized response exposes diagnostics only."
			value:     cueFlowPromotedProjectionBindingSlice.fixtures.bad.keywordRelevance.normalizedResponse.diagnostics.status
			rationale: "The non-accepted branch exports diagnostics status from the normalized root response."
		}
		"nonaccepted_response_rejects_agent_context": {
			id:        "nonaccepted_response_rejects_agent_context"
			source:    "cue/patterns/domain/schema.cue"
			claim:     "Non-accepted normalized response rejects agentContext."
			value:     true
			rationale: "The non-accepted branch of #NormalizedRootResponse constrains agentContext to bottom."
		}
		"adapter.branches_on_consumable": {
			id:        "adapter.branches_on_consumable"
			source:    _tracePath
			claim:     "Go branches on consumable.accepted/status."
			value:     true
			rationale: "The trace records accepted and rejected consumable states at the adapter boundary."
		}
		"adapter.consumes_normalized_response_fields": {
			id:        "adapter.consumes_normalized_response_fields"
			source:    _tracePath
			claim:     "Go consumes normalized response fields."
			value:     true
			rationale: "The trace includes normalizedResponse, agentContext, diagnostics, and consumable fields."
		}
		"adapter.does_not_consume_promotion_internals": {
			id:        "adapter.does_not_consume_promotion_internals"
			source:    _reviewPath
			claim:     "Go does not consume promotion internals for exposure decisions."
			value:     true
			rationale: "The review records promotion internals as non-consumed by the adapter exposure branch."
		}
		"adapter.action_classification": {
			id:        "adapter.action_classification"
			source:    _tracePath
			claim:     "Adapter action classification remains adapter/emitter/enforcer."
			value:     "adapter/emitter/enforcer"
			rationale: "The review green-lights Go only as adapter, emitter, and boundary enforcer."
		}
		"adapter.not_policy_source": {
			id:        "adapter.not_policy_source"
			source:    _reviewPath
			claim:     "Go does not become the validation or authorization policy source."
			value:     true
			rationale: "Policy remains in CUE root contracts; Go consumes the normalized boundary."
		}
		"estimator.method_is_rough_not_tokenizer_exact": {
			id:        "estimator.method_is_rough_not_tokenizer_exact"
			source:    _reviewPath
			claim:     "The estimator method is rough, not tokenizer exact."
			value:     "rough byte/line/file estimate; not tokenizer exact"
			rationale: "The review and trace both label the estimate as rough."
		}
	}
}

_authorityBindingGate: domain.#ValidationGate & {
	id:          "authority-binding"
	description: "Validate that root schema and scheme contracts bind workflow authority and adapter exposure."
	_rootShape: _observedFacts.facts["root.schema_owns_validation_contract_shape"] & {value: true}
	_schemeShape: _observedFacts.facts["scheme.fragments_conform_to_root_contracts"] & {value: true}
	_fragmentsOnly: _observedFacts.facts["task_patterns_provide_fragments_not_authority_roots"] & {value: true}
	_derived: _observedFacts.facts["promotion.outcome_derived_by_cue_unification"] & {value: true}
	_boundary: _observedFacts.facts["normalized_response_is_adapter_boundary"] & {value: true}
	_noBypass: _observedFacts.facts["adapter.does_not_bypass_promotion_root_authority"] & {value: true}
	requirements: [
		{
			id:          "req.root-validation-contract-owned"
			description: "Root schema owns validation contract shape."
			observedFactRefs: ["root.schema_owns_validation_contract_shape"]
			expected: ["true"]
		},
		{
			id:          "req.scheme-fragments-root-conformant"
			description: "Scheme fragments conform to root-owned promotion and validation contracts."
			observedFactRefs: ["scheme.fragments_conform_to_root_contracts", "task_patterns_provide_fragments_not_authority_roots"]
			expected: ["true", "true"]
		},
		{
			id:          "req.adapter-boundary-no-bypass"
			description: "Normalized response is the adapter boundary and the adapter does not bypass root promotion."
			observedFactRefs: ["promotion.outcome_derived_by_cue_unification", "normalized_response_is_adapter_boundary", "adapter.does_not_bypass_promotion_root_authority"]
			expected: ["true", "true", "true"]
		},
	]
	observedFactsUsed: [
		"root.schema_owns_validation_contract_shape",
		"scheme.fragments_conform_to_root_contracts",
		"task_patterns_provide_fragments_not_authority_roots",
		"promotion.outcome_derived_by_cue_unification",
		"normalized_response_is_adapter_boundary",
		"adapter.does_not_bypass_promotion_root_authority",
	]
	outcome: {
		status:    "passed"
		rationale: "Root-owned validation contracts, scheme fragments, derived promotion, and normalized adapter boundary unified."
	}
	rationale: "This gate fails if any observed authority-binding fact does not unify with the root-owned expected value."
}

_promotionBehaviorGate: domain.#ValidationGate & {
	id:          "promotion-behavior"
	description: "Validate accepted, fallback, and bad promotion gate behavior."
	_goodAccepted: _observedFacts.facts["promotion.good_selected_pattern_accepted"] & {value: true}
	_fallbackAccepted: _observedFacts.facts["promotion.bounded_fallback_accepted"] & {value: true}
	_keywordRejected: _observedFacts.facts["promotion.keyword_relevance_not_authorized"] & {value: false}
	_missingRelation: _observedFacts.facts["promotion.missing_relation_ref_not_accepted"] & {value: false}
	_rejectedRelation: _observedFacts.facts["promotion.rejected_relation_not_allowed"] & {value: false}
	_badCasesNotAccepted: _observedFacts.facts["promotion.bad_cases_not_accepted"] & {value: true}
	_keywordStatus:  cueFlowPromotionByUnificationSlice.proofs.bad.keywordRelevance.outcome.status & "drift"
	_missingStatus:  cueFlowPromotionByUnificationSlice.proofs.bad.missingRelationRef.outcome.status & "incomplete"
	_rejectedStatus: cueFlowPromotionByUnificationSlice.proofs.bad.rejectedRelation.outcome.status & "rejected"
	requirements: [
		{
			id:          "req.good-and-fallback-accepted"
			description: "Accepted and bounded fallback cases derive accepted true."
			observedFactRefs: ["promotion.good_selected_pattern_accepted", "promotion.bounded_fallback_accepted"]
			expected: ["true", "true"]
		},
		{
			id:          "req.bad-cases-not-accepted"
			description: "Keyword relevance, missing relationRef, and rejected relation cases derive accepted false."
			observedFactRefs: ["promotion.keyword_relevance_not_authorized", "promotion.missing_relation_ref_not_accepted", "promotion.rejected_relation_not_allowed", "promotion.bad_cases_not_accepted"]
			expected: ["false", "false", "false", "true"]
		},
	]
	observedFactsUsed: [
		"promotion.good_selected_pattern_accepted",
		"promotion.bounded_fallback_accepted",
		"promotion.keyword_relevance_not_authorized",
		"promotion.missing_relation_ref_not_accepted",
		"promotion.rejected_relation_not_allowed",
		"promotion.bad_cases_not_accepted",
	]
	outcome: {
		status:    "passed"
		rationale: "Promotion fixtures unify with expected accepted, drift, incomplete, and rejected outcomes."
	}
	rationale: "This gate binds task-pattern promotion behavior to existing root-owned promotion gate fixtures."
}

_exposureBindingGate: domain.#ValidationGate & {
	id:          "exposure-binding"
	description: "Validate normalized response exposure for accepted and non-accepted outcomes."
	_agentContext: _observedFacts.facts["accepted_response_exposes_agent_context"] & {value: "cue/patterns/domain/schema.cue"}
	_diagnosticsOnly: _observedFacts.facts["nonaccepted_response_exposes_diagnostics_only"] & {value: "drift"}
	_noAgentContext: _observedFacts.facts["nonaccepted_response_rejects_agent_context"] & {value: true}
	_rejectedExposed: _observedFacts.facts["review.rejected_exposed_file_count"] & {value: 0}
	_rejectedDeniedLoad: _observedFacts.facts["review.rejected_denied_load_count"] & {value: 2 & >0}
	requirements: [
		{
			id:          "req.accepted-agent-context"
			description: "Accepted normalized response exposes agentContext."
			observedFactRefs: ["accepted_response_exposes_agent_context"]
			expected: ["agentContext present"]
		},
		{
			id:          "req.nonaccepted-diagnostics-only"
			description: "Non-accepted normalized response exposes diagnostics and rejects agentContext."
			observedFactRefs: ["nonaccepted_response_exposes_diagnostics_only", "nonaccepted_response_rejects_agent_context"]
			expected: ["diagnostics present", "agentContext rejected"]
		},
		{
			id:          "req.rejected-load-shape"
			description: "Rejected runtime path exposes no files and records denied loads."
			observedFactRefs: ["review.rejected_exposed_file_count", "review.rejected_denied_load_count"]
			expected: ["0", ">0"]
		},
	]
	observedFactsUsed: [
		"accepted_response_exposes_agent_context",
		"nonaccepted_response_exposes_diagnostics_only",
		"nonaccepted_response_rejects_agent_context",
		"review.rejected_exposed_file_count",
		"review.rejected_denied_load_count",
	]
	outcome: {
		status:    "passed"
		rationale: "Accepted response exposes agentContext; non-accepted response exposes diagnostics only and rejected runtime files remain zero."
	}
	rationale: "This gate fails if rejected responses can expose agent context or if denied-load diagnostics disappear."
}

_thinAdapterBoundaryGate: domain.#ValidationGate & {
	id:          "thin-adapter-boundary"
	description: "Validate Go remains a thin adapter/emitter/enforcer and not a policy source."
	_consumableBranch: _observedFacts.facts["adapter.branches_on_consumable"] & {value: true}
	_normalizedFields: _observedFacts.facts["adapter.consumes_normalized_response_fields"] & {value: true}
	_noInternals: _observedFacts.facts["adapter.does_not_consume_promotion_internals"] & {value: true}
	_classification: _observedFacts.facts["adapter.action_classification"] & {value: "adapter/emitter/enforcer"}
	_notPolicySource: _observedFacts.facts["adapter.not_policy_source"] & {value: true}
	requirements: [
		{
			id:          "req.adapter-branches-on-consumable"
			description: "Adapter branches on consumable.accepted/status."
			observedFactRefs: ["adapter.branches_on_consumable"]
			expected: ["true"]
		},
		{
			id:          "req.adapter-consumes-normalized-boundary"
			description: "Adapter consumes normalized response fields and not promotion internals for exposure decisions."
			observedFactRefs: ["adapter.consumes_normalized_response_fields", "adapter.does_not_consume_promotion_internals"]
			expected: ["true", "true"]
		},
		{
			id:          "req.adapter-not-policy-source"
			description: "Adapter remains adapter/emitter/enforcer and does not become policy source."
			observedFactRefs: ["adapter.action_classification", "adapter.not_policy_source"]
			expected: ["adapter/emitter/enforcer", "true"]
		},
	]
	observedFactsUsed: [
		"adapter.branches_on_consumable",
		"adapter.consumes_normalized_response_fields",
		"adapter.does_not_consume_promotion_internals",
		"adapter.action_classification",
		"adapter.not_policy_source",
	]
	outcome: {
		status:    "passed"
		rationale: "Adapter facts unify with the thin boundary contract and do not introduce a Go policy source."
	}
	rationale: "This gate is validation-only CUE; it adds no Go/MCP policy engine."
}

_runtimeReductionObservationGate: domain.#ValidationGate & {
	id:          "runtime-reduction-observation"
	description: "Validate rough projected context reduction evidence."
	_reviewExists: _observedFacts.facts["review.green_light_review_exists"] & {value: true}
	_traceExists: _observedFacts.facts["runtime.flow_trace_exists"] & {value: true}
	_acceptedFiles: _observedFacts.facts["review.accepted_exposed_file_count"] & {value: 3}
	_broadBytes: _observedFacts.facts["review.broad_surface_bytes"] & {value: 87137}
	_broadLines: _observedFacts.facts["review.broad_surface_lines"] & {value: 2618}
	_broadFiles: _observedFacts.facts["review.broad_surface_files"] & {value: 10}
	_projectedBytes: _observedFacts.facts["review.projected_surface_bytes"] & {value: 34229 & <87137}
	_projectedLines: _observedFacts.facts["review.projected_surface_lines"] & {value: 1026 & <2618}
	_projectedFiles: _observedFacts.facts["review.projected_surface_files"] & {value: 3 & <10}
	_byteReduction: _observedFacts.facts["review.reduction_bytes_percent"] & {value: 60.7 & >50}
	_lineReduction: _observedFacts.facts["review.reduction_lines_percent"] & {value: 60.8 & >50}
	_fileReduction: _observedFacts.facts["review.reduction_files_percent"] & {value: 70.0 & >50}
	_roughEstimator: _observedFacts.facts["estimator.method_is_rough_not_tokenizer_exact"] & {value: "rough byte/line/file estimate; not tokenizer exact"}
	requirements: [
		{
			id:          "req.review-and-trace-exist"
			description: "Review and runtime trace artifacts are present as observed evidence sources."
			observedFactRefs: ["review.green_light_review_exists", "runtime.flow_trace_exists"]
			expected: ["true", "true"]
		},
		{
			id:          "req.projected-surface-smaller"
			description: "Projected context bytes, lines, and file count are lower than broad input."
			observedFactRefs: ["review.broad_surface_bytes", "review.projected_surface_bytes", "review.broad_surface_lines", "review.projected_surface_lines", "review.broad_surface_files", "review.projected_surface_files"]
			expected: ["34229 < 87137", "1026 < 2618", "3 < 10"]
		},
		{
			id:          "req.material-rough-reduction"
			description: "Reduction values are material and estimator method is explicitly rough."
			observedFactRefs: ["review.reduction_bytes_percent", "review.reduction_lines_percent", "review.reduction_files_percent", "estimator.method_is_rough_not_tokenizer_exact"]
			expected: ["60.7", "60.8", "70.0", "rough, not tokenizer exact"]
		},
	]
	observedFactsUsed: [
		"review.green_light_review_exists",
		"runtime.flow_trace_exists",
		"review.accepted_exposed_file_count",
		"review.broad_surface_bytes",
		"review.broad_surface_lines",
		"review.broad_surface_files",
		"review.projected_surface_bytes",
		"review.projected_surface_lines",
		"review.projected_surface_files",
		"review.reduction_bytes_percent",
		"review.reduction_lines_percent",
		"review.reduction_files_percent",
		"estimator.method_is_rough_not_tokenizer_exact",
	]
	outcome: {
		status:    "passed"
		rationale: "Projected context surface is lower than broad input across bytes, lines, and files, with material rough reductions recorded."
	}
	rationale: "This gate records reduction as observation evidence only; it does not claim tokenizer-exact measurement."
}

cueFlowValidationAssessmentSlice: domain.#ValidationAssessment & {
	contract:      domain.#RootValidationContract
	observedFacts: _observedFacts
	validationGates: {
		authorityBinding:            _authorityBindingGate
		promotionBehavior:           _promotionBehaviorGate
		exposureBinding:             _exposureBindingGate
		thinAdapterBoundary:         _thinAdapterBoundaryGate
		runtimeReductionObservation: _runtimeReductionObservationGate
	}
	outcome: {
		status: "passed"
		gateResults: {
			authorityBinding:            validationGates.authorityBinding.outcome
			promotionBehavior:           validationGates.promotionBehavior.outcome
			exposureBinding:             validationGates.exposureBinding.outcome
			thinAdapterBoundary:         validationGates.thinAdapterBoundary.outcome
			runtimeReductionObservation: validationGates.runtimeReductionObservation.outcome
		}
		observedFactsUsed: observedFacts.factIDs
		violations: []
		missingFacts: []
		rationale: "RootValidationContract & ObservedFactSet & AuthorityBindingGate & PromotionBehaviorGate & ExposureBindingGate & ThinAdapterBoundaryGate & RuntimeReductionObservationGate unified to a passed validation assessment."
	}
	roughEdges: [
		"Observed runtime/review values are encoded manually from the current review and trace artifact for this slice.",
		"Reduction evidence uses rough bytes, newline-counted lines, and file counts; it is not tokenizer exact.",
		"The live runtime cases remain fixture-backed and narrow to the current CUE-flow adapter slice.",
	]
}
