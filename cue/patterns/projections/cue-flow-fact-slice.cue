package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#FactRootedRelationSlice: {
	schemaVersion: "cuerail.factRootedRelationSlice.v1"

	sourceFacts: [string]: domain.#SourceFact

	relationEdges: [...domain.#RelationEdge]

	sliceRequirements: [...domain.#SliceRequirement]
}

cueFlowFactRootedRelationSlice: #FactRootedRelationSlice & {
	sourceFacts: domain.sourceFacts

	relationEdges: [
		{
			id:        "rel.go-adapts-cue-flow"
			from:      "go-cue-flow-adapter"
			to:        "cuelang.org/go/tools/flow"
			artifact:  "cuelang.org/go/tools/flow"
			operation: "adapts"
			authority: "upstream-api-fact"
			stateKind: "interop-state"
			allowed:   true
			factRefs: [
				"flow.low_level_workflow_manager_based_on_cue_instance",
				"flow.new_controller_accepts_cue_instance_or_value_and_taskfunc",
			]
		},
		{
			id:        "rel.root-schema-declares-task-shape"
			from:      "root-cue-schema"
			to:        "cue-flow-task-fragment"
			artifact:  "cue.Value"
			operation: "declares"
			authority: "root-cue-schema"
			stateKind: "contract-state"
			allowed:   true
			factRefs: [
				"flow.task_corresponds_to_struct_in_cue_instance",
				"flow.package_does_not_define_task_shape",
			]
		},
		{
			id:        "rel.go-supplies-taskfunc"
			from:      "go-cue-flow-adapter"
			to:        "flow.TaskFunc"
			artifact:  "cuelang.org/go/tools/flow.TaskFunc"
			operation: "supplies"
			authority: "derived-from-root-schema"
			stateKind: "interop-state"
			allowed:   true
			factRefs: [
				"flow.user_supplies_taskfunc_for_cue_values_deemed_tasks",
				"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
			]
		},
		{
			id:        "rel.cue-task-fragment-derives-dependency-edge"
			from:      "cue-flow-task-fragment"
			to:        "cue-flow-dependency-edge"
			artifact:  "cue.Value"
			operation: "derives dependency"
			authority: "upstream-api-fact"
			stateKind: "dependency-state"
			allowed:   true
			factRefs: [
				"flow.dependencies_derive_from_references_between_task_fields",
				"flow.cyclic_dependencies_not_allowed",
			]
		},
		{
			id:         "rel.config-root-limits-task-search"
			from:       "flow.Config.Root"
			to:         "bounded-task-search"
			artifact:   "cuelang.org/go/tools/flow.Config"
			operation:  "limits"
			authority:  "upstream-api-fact"
			stateKind:  "containment-state"
			allowed:    true
			constraint: "Task search remains within the configured CUE path."
			factRefs: [
				"flow.config_root_limits_task_search_within_cue_path",
			]
		},
		{
			id:             "rel.go-declares-task-shape"
			from:           "go-cue-flow-adapter"
			to:             "task-shape"
			artifact:       "cue.Value"
			operation:      "declares"
			authority:      "go-adapter"
			stateKind:      "contract-state"
			allowed:        false
			classification: "architectural-drift"
			factRefs: [
				"flow.package_does_not_define_task_shape",
				"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
			]
		},
		{
			id:             "rel.go-enables-arbitrary-task-inference"
			from:           "go-cue-flow-adapter"
			to:             "arbitrary-task-inference"
			artifact:       "cuelang.org/go/tools/flow.Config.InferTasks"
			operation:      "enables"
			authority:      "go-adapter"
			stateKind:      "task-discovery-state"
			allowed:        false
			classification: "architectural-drift"
			constraint:     "May be allowed only when explicitly declared as risky and bounded by root schema."
			factRefs: [
				"flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious",
				"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
			]
		},
		{
			id:        "rel.runner-fills-typed-output-evidence"
			from:      "flow.Runner"
			to:        "typed-output/evidence"
			artifact:  "cuelang.org/go/tools/flow.Task.Fill"
			operation: "fills/emits"
			authority: "runner-produced-fill"
			stateKind: "evidence-state"
			allowed:   true
			factRefs: [
				"flow.task_fill_fills_output_values_after_runner_execution",
			]
		},
		{
			id:        "rel.root-schema-declares-authorization-evidence"
			from:      "root-cue-schema"
			to:        "authorization-evidence"
			artifact:  "domain.#AuthorizationEvidence"
			operation: "declares"
			authority: "root-cue-schema"
			stateKind: "contract-state"
			allowed:   true
			factRefs: [
				"root.authorization_evidence_is_root_owned",
				"root.relations_are_admitted_only_when_backed_by_facts",
			]
		},
		{
			id:        "rel.root-policy-authorizes-loaded-file"
			from:      "root-policy"
			to:        "loaded-file-evidence"
			artifact:  "domain.#LoadedFileEvidence"
			operation: "authorizes"
			authority: "root-policy"
			stateKind: "authorization-state"
			allowed:   true
			factRefs: [
				"root.file_loads_require_authorization_relation",
				"review.freeze_gate_rejects_relevance_only_loads",
			]
		},
		{
			id:        "rel.selected-pattern-authorizes-loaded-file"
			from:      "selected-pattern-contract"
			to:        "loaded-file-evidence"
			artifact:  "domain.#LoadedFileEvidence"
			operation: "authorizes"
			authority: "derived-from-root-schema"
			stateKind: "authorization-state"
			allowed:   true
			factRefs: [
				"root.authorization_evidence_is_root_owned",
				"root.file_loads_require_authorization_relation",
			]
		},
		{
			id:         "rel.bounded-fallback-authorizes-root-declared-surface"
			from:       "bounded-fallback"
			to:         "loaded-file-evidence"
			artifact:   "domain.#LoadedFileEvidence"
			operation:  "authorizes"
			authority:  "root-policy"
			stateKind:  "authorization-state"
			allowed:    true
			constraint: "Fallback loads are limited to explicit AGENTS.cue, index, or root-declared surfaces."
			factRefs: [
				"root.bounded_fallback_limits_loads_to_declared_surfaces",
				"root.file_loads_require_authorization_relation",
			]
		},
		{
			id:        "rel.go-emits-authorization-evidence"
			from:      "go-cue-flow-adapter"
			to:        "authorization-evidence"
			artifact:  "domain.#AuthorizationEvidence"
			operation: "emits"
			authority: "derived-from-root-schema"
			stateKind: "evidence-state"
			allowed:   true
			factRefs: [
				"flow.task_fill_fills_output_values_after_runner_execution",
				"root.authorization_evidence_is_root_owned",
			]
		},
		{
			id:             "rel.go-owns-load-authorization"
			from:           "go-cue-flow-adapter"
			to:             "load-authorization"
			artifact:       "domain.#AuthorizationEvidence"
			operation:      "owns"
			authority:      "go-adapter"
			stateKind:      "authorization-state"
			allowed:        false
			classification: "architectural-drift"
			factRefs: [
				"root.authorization_evidence_is_root_owned",
				"review.freeze_gate_rejects_relevance_only_loads",
			]
		},
		{
			id:             "rel.keyword-relevance-authorizes-load"
			from:           "keyword-relevance"
			to:             "load-authorization"
			artifact:       "file-load-request"
			operation:      "authorizes"
			authority:      "keyword-relevance"
			stateKind:      "authorization-state"
			allowed:        false
			classification: "architectural-drift"
			factRefs: [
				"root.file_loads_require_authorization_relation",
				"review.freeze_gate_rejects_relevance_only_loads",
			]
		},
	]

	sliceRequirements: [
		{
			id:          "req.fact-rooted-relations"
			description: "Every relation edge and slice requirement must be backed by a known upstream, root schema, fixture, or local review fact."
			requires: [
				"relationEdges.factRefs",
				"sliceRequirements.factRefs",
			]
			factRefs: [
				"root.relations_are_admitted_only_when_backed_by_facts",
				"fixture.fact_rooted_cue_flow_relation_slice_exports",
			]
		},
		{
			id:          "req.go-adapter-boundary"
			description: "Go may supply TaskFunc and Runner behavior for root-schema-declared CUE task values, but must not define task shape or broaden InferTasks by default."
			requires: [
				"rel.go-supplies-taskfunc",
				"rel.go-declares-task-shape",
				"rel.go-enables-arbitrary-task-inference",
			]
			factRefs: [
				"flow.package_does_not_define_task_shape",
				"flow.user_supplies_taskfunc_for_cue_values_deemed_tasks",
				"flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious",
				"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
			]
		},
		{
			id:          "req.typed-authorization-evidence"
			description: "Authorization evidence must be root-owned, typed, and backed by valid authorization relations with known fact references."
			requires: [
				"domain.#AuthorizationEvidence",
				"loadedFiles.relationRef",
				"loadedFiles.factRefs",
				"deniedLoads.rejectedRelationRef",
				"relationEdges.factRefs",
			]
			factRefs: [
				"root.authorization_evidence_is_root_owned",
				"root.file_loads_require_authorization_relation",
				"review.freeze_gate_rejects_relevance_only_loads",
				"fixture.typed_authorization_evidence_slice_exports",
			]
		},
	]
}
