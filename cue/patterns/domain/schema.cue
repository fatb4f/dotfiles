package domain

#SourceFactKind: "upstream-source" | "root-schema" | "fixture" | "local-review"

#SourceFactID:
	"flow.low_level_workflow_manager_based_on_cue_instance" |
	"flow.task_corresponds_to_struct_in_cue_instance" |
	"flow.package_does_not_define_task_shape" |
	"flow.user_supplies_taskfunc_for_cue_values_deemed_tasks" |
	"flow.new_controller_accepts_cue_instance_or_value_and_taskfunc" |
	"flow.dependencies_derive_from_references_between_task_fields" |
	"flow.cyclic_dependencies_not_allowed" |
	"flow.config_root_limits_task_search_within_cue_path" |
	"flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious" |
	"flow.task_fill_fills_output_values_after_runner_execution" |
	"root.relations_are_admitted_only_when_backed_by_facts" |
	"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks" |
	"root.authorization_evidence_is_root_owned" |
	"root.file_loads_require_authorization_relation" |
	"root.bounded_fallback_limits_loads_to_declared_surfaces" |
	"review.freeze_gate_rejects_relevance_only_loads" |
	"fixture.fact_rooted_cue_flow_relation_slice_exports" |
	"fixture.typed_authorization_evidence_slice_exports" |
	"root.promotion_gate_contract_is_root_owned" |
	"root.promotion_gate_outcome_is_derived" |
	"root.task_patterns_provide_promotion_fragments" |
	"root.rejected_relations_do_not_satisfy_promotion" |
	"fixture.promotion_by_unification_slice_exports" |
	"fixture.promoted_projection_binding_slice_exports"

#SourceFact: {
	id:          #SourceFactID
	kind:        #SourceFactKind
	source:      string
	claim:       string
	observedIn?: string
	consequence: string
}

#FactRefList: [#SourceFactID, ...#SourceFactID]

#RelationEdge: {
	id:        string
	from:      string
	to:        string
	artifact:  string
	operation: string
	authority: string
	stateKind: string
	allowed:   bool

	classification?: string
	constraint?:     string
	factRefs:        #FactRefList
}

#SliceRequirement: {
	id:          string
	description: string
	requires: [...string]
	factRefs: #FactRefList
}

#RelationRefID:
	"rel.go-adapts-cue-flow" |
	"rel.root-schema-declares-task-shape" |
	"rel.go-supplies-taskfunc" |
	"rel.cue-task-fragment-derives-dependency-edge" |
	"rel.config-root-limits-task-search" |
	"rel.go-declares-task-shape" |
	"rel.go-enables-arbitrary-task-inference" |
	"rel.runner-fills-typed-output-evidence" |
	"rel.root-schema-declares-authorization-evidence" |
	"rel.root-policy-authorizes-loaded-file" |
	"rel.selected-pattern-authorizes-loaded-file" |
	"rel.bounded-fallback-authorizes-root-declared-surface" |
	"rel.go-emits-authorization-evidence" |
	"rel.go-owns-load-authorization" |
	"rel.keyword-relevance-authorizes-load"

#RelationRefList: [#RelationRefID, ...#RelationRefID]

#AuthorizationSource:
	"root-policy" |
	"selected-pattern" |
	"bounded-fallback" |
	"derived-from-root-schema" |
	"fixture" |
	"rejected-drift"

#AuthorizationRelationRefID:
	"rel.root-policy-authorizes-loaded-file" |
	"rel.selected-pattern-authorizes-loaded-file" |
	"rel.bounded-fallback-authorizes-root-declared-surface"

#RejectedAuthorizationRelationRefID:
	"rel.go-owns-load-authorization" |
	"rel.keyword-relevance-authorizes-load" |
	"rel.go-enables-arbitrary-task-inference"

#LoadedFileEvidence: {
	path:             string
	authorizedBy:     #AuthorizationSource
	sourcePatternID?: string
	relationRef:      #AuthorizationRelationRefID
	factRefs:         #FactRefList
	reason:           string
}

#DeniedLoadEvidence: {
	path:                 string
	deniedBy:             #AuthorizationSource
	relationRef?:         #AuthorizationRelationRefID
	rejectedRelationRef?: #RejectedAuthorizationRelationRefID
	factRefs:             #FactRefList
	reason:               string
	requestedBy?:         string
	classification?:      string
}

#AuthorizationEvidence: {
	selectedPatternIDs: [...string]
	loadedFiles: [...#LoadedFileEvidence]
	deniedLoads: [...#DeniedLoadEvidence]
	authorizationSource: #AuthorizationSource
	rationale:           string
	relationRefs:        #RelationRefList
	factRefs:            #FactRefList
}

#GateInvariantID:
	"keyword-relevance-is-not-load-authorization" |
	"go-adapter-does-not-own-policy" |
	"selected-pattern-files-require-authorization-evidence" |
	"bounded-fallback-limits-loads-to-root-declared-surfaces" |
	"promotion-relations-require-known-factrefs" |
	"promotion-requirements-require-known-factrefs" |
	"accepted-is-derived-not-fixture-authored"

#GateInvariant: {
	id:       #GateInvariantID
	mustHold: string
	factRefs: #FactRefList
}

#PromotionGateCaseID:
	"normal-promotion" |
	"bounded-fallback-promotion" |
	"rejected-drift" |
	"incomplete-evidence" |
	"invalid-relation" |
	"invalid-fact-ref" |
	"invalid-authorization-source"

#PromotionGateStatus: "accepted" | "rejected" | "drift" | "incomplete"

#PromotionGateCase: {
	id:                  #PromotionGateCaseID
	status:              #PromotionGateStatus
	authorizationSource: #AuthorizationSource
	allowedRelationRefs: [...#AuthorizationRelationRefID]
	requiredInvariantRefs: [...#GateInvariantID]
	requiredFactRefs: #FactRefList
	rationale:        string
}

#PromotionGateOutcome:
	{
		status:          "accepted"
		accepted:        true
		classification?: string
		violations: []
		missingRequirements: []
		rationale: string
	} |
	{
		status:          "rejected"
		accepted:        false
		classification?: string
		violations: [...string]
		missingRequirements: [...string]
		rationale: string
	} |
	{
		status:         "drift"
		accepted:       false
		classification: string
		violations: [...string]
		missingRequirements: [...string]
		rationale: string
	} |
	{
		status:          "incomplete"
		accepted:        false
		classification?: string
		violations: [...string]
		missingRequirements: [...string]
		rationale: string
	}

#AllowedPromotionRelation: #RelationEdge & {
	allowed:   true
	operation: "authorizes"
	factRefs:  #FactRefList
}

#PatternPromotionFragment: {
	id:        string
	patternID: string
	requires: [...#SliceRequirement]
	invariantRefs: [...#GateInvariantID]
	allowedRelationRefs: [...#AuthorizationRelationRefID]
	evidenceExpectations: [...string]
	factRefs:  #FactRefList
	rationale: string
}

#PromotionGate: {
	id:        string
	patternID: string
	case:      #PromotionGateCase

	fragment: #PatternPromotionFragment
	requires: [...#SliceRequirement]
	invariants: [...#GateInvariant]
	evidence: #AuthorizationEvidence & {
		authorizationSource: case.authorizationSource
	}
	relations: [...#AllowedPromotionRelation]
	factRefs: #FactRefList
	rejectedRelations?: [...#RelationEdge]
	attemptedOutcome?: {
		status:   #PromotionGateStatus
		accepted: bool
	}

	outcome: #PromotionGateOutcome & {
		status: case.status
	}
	rationale: string
}

#PromotedProjection:
	{
		promotionOutcome: #PromotionGateOutcome & {
			accepted: true
		}
		selectedPatternIDs: [...string]
		exposedFiles: [...#LoadedFileEvidence]
		projectedPrompt:  string
		promptProjection: string
		evidenceSummary: {
			selectedPatternIDs: [...string]
			exposedFiles: [...#LoadedFileEvidence]
			authorizationSource: #AuthorizationSource
			relationRefs:        #RelationRefList
			factRefs:            #FactRefList
			rationale:           string
		}
		contextProjection: {
			authorizationSource: #AuthorizationSource
			rationale:           string
			relationRefs:        #RelationRefList
			factRefs:            #FactRefList
		}
		relationRefs: #RelationRefList
		factRefs:     #FactRefList
		rationale:    string
		evidenceRefs: #FactRefList
	} |
	{
		promotionOutcome: #PromotionGateOutcome & {
			accepted: false
		}
		diagnostics: {
			status:          #PromotionGateStatus
			classification?: string
			violations: [...string]
			missingRequirements: [...string]
			rationale: string
			deniedLoads: [...#DeniedLoadEvidence]
			relationRefs: #RelationRefList
			factRefs:     #FactRefList
		}
		evidenceRefs:        #FactRefList
		selectedPatternIDs?: _|_
		exposedFiles?:       _|_
		projectedPrompt?:    _|_
		promptProjection?:   _|_
		evidenceSummary?:    _|_
		contextProjection?:  _|_
		relationRefs?:       _|_
		factRefs?:           _|_
	}

#AgentConsumableContext: {
	selectedPatternIDs: [...string]
	exposedFiles: [...#LoadedFileEvidence]
	projectedPrompt:  string
	promptProjection: string
	evidenceSummary: {
		selectedPatternIDs: [...string]
		exposedFiles: [...#LoadedFileEvidence]
		authorizationSource: #AuthorizationSource
		relationRefs:        #RelationRefList
		factRefs:            #FactRefList
		rationale:           string
	}
	relationRefs: #RelationRefList
	factRefs:     #FactRefList
	rationale:    string
}

#NormalizedRootResponse: ({
	schemaVersion: "cuerail.normalizedRootResponse.v1"
	requestID:     string
	promotion: #PromotedProjection & {
		promotionOutcome: {
			accepted: true
		}
	}
	consumable: {
		accepted: promotion.promotionOutcome.accepted
		status:   promotion.promotionOutcome.status
	}
	agentContext: #AgentConsumableContext
	diagnostics?: _|_
} | {
	schemaVersion: "cuerail.normalizedRootResponse.v1"
	requestID:     string
	promotion: #PromotedProjection & {
		promotionOutcome: {
			accepted: false
		}
	}
	consumable: {
		accepted: promotion.promotionOutcome.accepted
		status:   promotion.promotionOutcome.status
	}
	diagnostics:   promotion.diagnostics
	agentContext?: _|_
})

#ObservedFactID:
	"review.green_light_review_exists" |
	"runtime.flow_trace_exists" |
	"review.accepted_exposed_file_count" |
	"review.rejected_exposed_file_count" |
	"review.rejected_denied_load_count" |
	"review.broad_surface_bytes" |
	"review.broad_surface_lines" |
	"review.broad_surface_files" |
	"review.projected_surface_bytes" |
	"review.projected_surface_lines" |
	"review.projected_surface_files" |
	"review.reduction_bytes_percent" |
	"review.reduction_lines_percent" |
	"review.reduction_files_percent" |
	"root.schema_owns_validation_contract_shape" |
	"scheme.fragments_conform_to_root_contracts" |
	"task_patterns_provide_fragments_not_authority_roots" |
	"promotion.outcome_derived_by_cue_unification" |
	"normalized_response_is_adapter_boundary" |
	"adapter.does_not_bypass_promotion_root_authority" |
	"promotion.good_selected_pattern_accepted" |
	"promotion.bounded_fallback_accepted" |
	"promotion.keyword_relevance_not_authorized" |
	"promotion.missing_relation_ref_not_accepted" |
	"promotion.rejected_relation_not_allowed" |
	"promotion.bad_cases_not_accepted" |
	"accepted_response_exposes_agent_context" |
	"nonaccepted_response_exposes_diagnostics_only" |
	"nonaccepted_response_rejects_agent_context" |
	"adapter.branches_on_consumable" |
	"adapter.consumes_normalized_response_fields" |
	"adapter.does_not_consume_promotion_internals" |
	"adapter.action_classification" |
	"adapter.not_policy_source" |
	"estimator.method_is_rough_not_tokenizer_exact"

#ObservedFact: {
	id:          #ObservedFactID
	source:      string
	claim:       string
	value:       _
	observedIn?: string
	rationale:   string
}

#ObservedFactSet: {
	facts: [#ObservedFactID]: #ObservedFact
	factIDs: [...#ObservedFactID]
	rationale: string
}

#ValidationGateID:
	"authority-binding" |
	"promotion-behavior" |
	"exposure-binding" |
	"thin-adapter-boundary" |
	"runtime-reduction-observation"

#ValidationStatus: "passed" | "failed" | "drift" | "incomplete"

#ValidationRequirement: {
	id:          string
	description: string
	observedFactRefs: [...#ObservedFactID]
	expected: [...string]
}

#ValidationGateOutcome:
	{
		status:   "passed"
		accepted: true
		violations: []
		missingFacts: []
		rationale: string
		gateResults?: [string]: #ValidationGateOutcome
		observedFactsUsed?: [...#ObservedFactID]
	} |
	{
		status:   "failed"
		accepted: false
		violations: [...string]
		missingFacts: [...#ObservedFactID]
		rationale: string
		gateResults?: [string]: #ValidationGateOutcome
		observedFactsUsed?: [...#ObservedFactID]
	} |
	{
		status:   "drift"
		accepted: false
		violations: [...string]
		missingFacts: [...#ObservedFactID]
		rationale: string
		gateResults?: [string]: #ValidationGateOutcome
		observedFactsUsed?: [...#ObservedFactID]
	} |
	{
		status:   "incomplete"
		accepted: false
		violations: [...string]
		missingFacts: [...#ObservedFactID]
		rationale: string
		gateResults?: [string]: #ValidationGateOutcome
		observedFactsUsed?: [...#ObservedFactID]
	}

#ValidationGate: {
	id:          #ValidationGateID
	description: string
	requirements: [...#ValidationRequirement]
	observedFactsUsed: [...#ObservedFactID]
	outcome:   #ValidationGateOutcome
	rationale: string
}

#RootValidationContract: {
	schemaVersion: "cuerail.rootValidationContract.v1"
	source:        "cue/patterns/domain/schema.cue"
	model: {
		gateEvaluation: "pure-cue-unification"
		observedFacts:  "inputs"
		outcome:        "derived"
	}
	gateIDs: [
		"authority-binding",
		"promotion-behavior",
		"exposure-binding",
		"thin-adapter-boundary",
		"runtime-reduction-observation",
	]
	invariant: "Validation gates are pure CUE unification over observed facts."
}

#ValidationAssessment: {
	schemaVersion: "cuerail.validationAssessmentSlice.v1"
	contract:      #RootValidationContract
	observedFacts: #ObservedFactSet
	validationGates: {
		authorityBinding: #ValidationGate & {id: "authority-binding"}
		promotionBehavior: #ValidationGate & {id: "promotion-behavior"}
		exposureBinding: #ValidationGate & {id: "exposure-binding"}
		thinAdapterBoundary: #ValidationGate & {id: "thin-adapter-boundary"}
		runtimeReductionObservation: #ValidationGate & {id: "runtime-reduction-observation"}
	}
	outcome: #ValidationGateOutcome & {
		status: "passed"
	}
	roughEdges?: [...string]
}

#ValidationReportManifest: {
	schemaVersion: "cuerail.validationReportManifest.v1"
	reportID:      string
	generatedFrom: {
		projection: string
		command:    string
	}
	validationAssessmentRef: string
	validationContractRef:   string
	observedFacts:           #ObservedFactSet
	gateResults: {
		authorityBinding:            #ValidationGateOutcome
		promotionBehavior:           #ValidationGateOutcome
		exposureBinding:             #ValidationGateOutcome
		thinAdapterBoundary:         #ValidationGateOutcome
		runtimeReductionObservation: #ValidationGateOutcome
	}
	overallOutcome: #ValidationGateOutcome
	sourceArtifacts: [...string]
	validationCommands: [...string]
	exportCommands: [...string]
	runtimeEvidence: {
		acceptedExposedFiles:  int
		rejectedExposedFiles:  int
		rejectedDeniedLoads:   int
		broadSurfaceBytes:     int
		broadSurfaceLines:     int
		broadSurfaceFiles:     int
		projectedSurfaceBytes: int
		projectedSurfaceLines: int
		projectedSurfaceFiles: int
		byteReductionPercent:  number
		lineReductionPercent:  number
		fileReductionPercent:  number
		estimatorMethod:       string
	}
	contextReduction: {
		broad: {
			bytes: int
			lines: int
			files: int
		}
		projected: {
			bytes: int
			lines: int
			files: int
		}
		reductionPercent: {
			bytes: number
			lines: number
			files: number
		}
	}
	roughEdges: [...string]
	nextHardening: [...string]
	rationale: string
}

sourceFacts: {
	"flow.low_level_workflow_manager_based_on_cue_instance": {
		id:          "flow.low_level_workflow_manager_based_on_cue_instance"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "flow is a low-level workflow manager based on a CUE Instance."
		observedIn:  "cuelang.org/go/tools/flow package overview"
		consequence: "Adapter relations target CUE instance/value workflow evaluation, not a generic runtime."
	}
	"flow.task_corresponds_to_struct_in_cue_instance": {
		id:          "flow.task_corresponds_to_struct_in_cue_instance"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "A Task corresponds to a struct in a CUE instance."
		observedIn:  "cuelang.org/go/tools/flow Task documentation"
		consequence: "Task shape originates in CUE data/schema."
	}
	"flow.package_does_not_define_task_shape": {
		id:          "flow.package_does_not_define_task_shape"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "The flow package does not define what a Task looks like."
		observedIn:  "cuelang.org/go/tools/flow package overview"
		consequence: "Go may recognize declared CUE task values but must not become the schema authority."
	}
	"flow.user_supplies_taskfunc_for_cue_values_deemed_tasks": {
		id:          "flow.user_supplies_taskfunc_for_cue_values_deemed_tasks"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "The user supplies a TaskFunc that creates a Runner for cue.Values considered tasks."
		observedIn:  "cuelang.org/go/tools/flow TaskFunc documentation"
		consequence: "Go supplies adaptation behavior for task values already admitted by CUE."
	}
	"flow.new_controller_accepts_cue_instance_or_value_and_taskfunc": {
		id:          "flow.new_controller_accepts_cue_instance_or_value_and_taskfunc"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "New accepts a cue.InstanceOrValue plus a TaskFunc."
		observedIn:  "cuelang.org/go/tools/flow New documentation"
		consequence: "The adapter boundary is CUE value evaluation plus user-supplied task recognition."
	}
	"flow.dependencies_derive_from_references_between_task_fields": {
		id:          "flow.dependencies_derive_from_references_between_task_fields"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "Task dependencies are derived from references between task fields."
		observedIn:  "cuelang.org/go/tools/flow package overview"
		consequence: "Dependency edges are modeled as CUE-reference-derived facts."
	}
	"flow.cyclic_dependencies_not_allowed": {
		id:          "flow.cyclic_dependencies_not_allowed"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "Cyclic task dependencies are not allowed."
		observedIn:  "cuelang.org/go/tools/flow package overview"
		consequence: "The slice must reject cyclic dependency interpretation."
	}
	"flow.config_root_limits_task_search_within_cue_path": {
		id:          "flow.config_root_limits_task_search_within_cue_path"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "Config.Root limits task search within a CUE path."
		observedIn:  "cuelang.org/go/tools/flow Config.Root documentation"
		consequence: "Root is a factual containment primitive for task discovery boundaries."
	}
	"flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious": {
		id:          "flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "InferTasks can look for task structs in arbitrary data and may produce spurious matches."
		observedIn:  "cuelang.org/go/tools/flow Config.InferTasks documentation"
		consequence: "Default stance is InferTasks false unless explicitly modeled as risky and bounded."
	}
	"flow.task_fill_fills_output_values_after_runner_execution": {
		id:          "flow.task_fill_fills_output_values_after_runner_execution"
		kind:        "upstream-source"
		source:      "https://pkg.go.dev/cuelang.org/go/tools/flow"
		claim:       "Task.Fill fills task output values after runner execution."
		observedIn:  "cuelang.org/go/tools/flow Task.Fill documentation"
		consequence: "Evidence and output emission are runner-produced fills, not policy authorship."
	}
	"root.relations_are_admitted_only_when_backed_by_facts": {
		id:          "root.relations_are_admitted_only_when_backed_by_facts"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Relations are admitted only when backed by facts."
		consequence: "Relation edges and slice requirements require known fact references."
	}
	"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks": {
		id:          "root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Go may supply TaskFunc and Runner behavior for root-schema-declared CUE task values."
		consequence: "Go may not define task shape or broaden InferTasks unless the root schema admits that risk."
	}
	"root.authorization_evidence_is_root_owned": {
		id:          "root.authorization_evidence_is_root_owned"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Authorization evidence is declared by the root schema."
		consequence: "Adapters may emit evidence values but must not own authorization policy."
	}
	"root.file_loads_require_authorization_relation": {
		id:          "root.file_loads_require_authorization_relation"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "A loaded file evidence record requires an authorization relation and known facts."
		consequence: "Relevance alone is insufficient to authorize file loading."
	}
	"root.bounded_fallback_limits_loads_to_declared_surfaces": {
		id:          "root.bounded_fallback_limits_loads_to_declared_surfaces"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Bounded fallback loads are limited to explicit AGENTS.cue, index, or root-declared surfaces."
		consequence: "Fallback mode remains an explicit root-owned authorization source."
	}
	"review.freeze_gate_rejects_relevance_only_loads": {
		id:          "review.freeze_gate_rejects_relevance_only_loads"
		kind:        "local-review"
		source:      "freeze review"
		claim:       "A file load is authorized only when a valid relation edge and supporting facts admit it."
		consequence: "Keyword relevance and hidden adapter-owned policy are classified as architectural drift."
	}
	"fixture.fact_rooted_cue_flow_relation_slice_exports": {
		id:          "fixture.fact_rooted_cue_flow_relation_slice_exports"
		kind:        "fixture"
		source:      "cue/patterns/projections/cue-flow-fact-slice.cue"
		claim:       "The fact-rooted CUE flow relation fixture exports."
		consequence: "Fixture/export proof covers the relation contract shape."
	}
	"fixture.typed_authorization_evidence_slice_exports": {
		id:          "fixture.typed_authorization_evidence_slice_exports"
		kind:        "fixture"
		source:      "cue/patterns/projections/authorization-evidence-slice.cue"
		claim:       "The typed authorization evidence fixture exports."
		consequence: "Fixture/export proof covers authorization evidence shape and admissibility fields."
	}
	"root.promotion_gate_contract_is_root_owned": {
		id:          "root.promotion_gate_contract_is_root_owned"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "The root schema owns the generic promotion gate interface."
		consequence: "Task patterns may provide fragments, but may not redefine promotion gate shape."
	}
	"root.promotion_gate_outcome_is_derived": {
		id:          "root.promotion_gate_outcome_is_derived"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Promotion accepted state is projected from the unified gate outcome, not authored as fixture input."
		consequence: "A bad fixture cannot self-declare accepted without unifying with an accepted gate case."
	}
	"root.task_patterns_provide_promotion_fragments": {
		id:          "root.task_patterns_provide_promotion_fragments"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Task patterns bundle thin promotion fragments containing requirements, invariant refs, and relation expectations."
		consequence: "Promotion policy remains root-mediated while patterns declare their local constraints."
	}
	"root.rejected_relations_do_not_satisfy_promotion": {
		id:          "root.rejected_relations_do_not_satisfy_promotion"
		kind:        "root-schema"
		source:      "cue/patterns/domain/schema.cue"
		claim:       "Rejected relation edges may be exported as drift evidence but cannot satisfy allowed promotion relation requirements."
		consequence: "Promotion evidence relations must be allowed and backed by known facts."
	}
	"fixture.promotion_by_unification_slice_exports": {
		id:          "fixture.promotion_by_unification_slice_exports"
		kind:        "fixture"
		source:      "cue/patterns/projections/promotion-by-unification-slice.cue"
		claim:       "The promotion-by-unification projection exports."
		consequence: "Promotion status is visible as a replayable CUE proof expression normal form."
	}
	"fixture.promoted_projection_binding_slice_exports": {
		id:          "fixture.promoted_projection_binding_slice_exports"
		kind:        "fixture"
		source:      "cue/patterns/projections/promoted-projection-binding-slice.cue"
		claim:       "The promoted projection binding projection exports."
		consequence: "Only accepted promotion outcomes expose agent-consumable context in the normalized root response."
	}
}

#DomainSurface: {
	summary: string
	paths: [...string]
	commands?: [...string]
	authorities?: [...string]
}

#DomainScopes: {
	owned: [...string]
	adjacent: [...string]
	forbidden: [...string]
}

#PatternGoodPattern: {
	id:      string
	summary: string
	when?:   string
}

#PatternFailure: {
	id:        string
	symptom:   string
	avoidance: string
}

#PatternInvariant: {
	id:       string
	mustHold: string
}

#PatternGateRequirement: {
	id:             string
	requiredBefore: "review" | "gate" | "eval" | "commit"
	proof:          string
}

#DomainNodePattern: {
	id:     string
	domain: string

	surface: #DomainSurface
	scopes:  #DomainScopes

	discovery: {
		authorityPaths: [...string]
		entrypoints: [...string]
		requiredLoads: [...string]
		forbiddenLoads: [...string]
		staleSignals: [...string]
	}

	knownGoodPatterns: [...#PatternGoodPattern]
	knownFailures: [...#PatternFailure]
	invariants: [...#PatternInvariant]

	gatePromotionRequirements: [...#PatternGateRequirement]

	proofs: {
		commands: [...string]
		artifacts: [...string]
	}
}
