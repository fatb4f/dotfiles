package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#AuthorizationEvidenceSlice: {
	schemaVersion: "cueflow.authorizationEvidenceSlice.v1"

	sourceFacts: [string]: domain.#SourceFact

	relationEdges: [...domain.#RelationEdge]

	good: domain.#AuthorizationEvidence

	bad: domain.#AuthorizationEvidence

	fallback: domain.#AuthorizationEvidence
}

cueFlowAuthorizationEvidenceSlice: #AuthorizationEvidenceSlice & {
	sourceFacts: domain.sourceFacts

	relationEdges: cueFlowFactRootedRelationSlice.relationEdges

	good: {
		selectedPatternIDs: [
			"cue-flow-fact-rooted-relation",
			"selected-pattern-contract",
		]
		authorizationSource: "selected-pattern"
		rationale:           "Selected pattern files are loaded because the selected pattern contract authorizes them through root-schema-derived relations backed by known facts."
		relationRefs: [
			"rel.root-schema-declares-authorization-evidence",
			"rel.selected-pattern-admits-loaded-file",
			"rel.go-emits-authorization-evidence",
		]
		factRefs: [
			"contract.load_evidence_is_declared",
			"root.file_loads_require_authorization_relation",
			"flow.task_fill_fills_output_values_after_runner_execution",
			"fixture.typed_authorization_evidence_slice_exports",
		]
		loadedFiles: [
			{
				path:            "cue/patterns/domain/schema.cue"
				authorizedBy:    "selected-pattern"
				sourcePatternID: "selected-pattern-contract"
				relationRef:     "rel.selected-pattern-admits-loaded-file"
				factRefs: [
					"contract.load_evidence_is_declared",
					"root.file_loads_require_authorization_relation",
				]
				reason: "The selected pattern contract requires the contract schema that declares authorization evidence."
			},
			{
				path:            "cue/patterns/projections/codex-slice.cue"
				authorizedBy:    "selected-pattern"
				sourcePatternID: "selected-pattern-contract"
				relationRef:     "rel.selected-pattern-admits-loaded-file"
				factRefs: [
					"root.file_loads_require_authorization_relation",
					"review.freeze_gate_rejects_relevance_only_loads",
				]
				reason: "The selected projection is loaded through the selected pattern contract, not neighboring-file relevance."
			},
			{
				path:            "cue/patterns/projections/cue-flow-fact-slice.cue"
				authorizedBy:    "selected-pattern"
				sourcePatternID: "cue-flow-fact-rooted-relation"
				relationRef:     "rel.selected-pattern-admits-loaded-file"
				factRefs: [
					"fixture.fact_rooted_cue_flow_relation_slice_exports",
					"root.relations_are_admitted_only_when_backed_by_facts",
				]
				reason: "The fact-rooted relation fixture is the selected relation substrate for authorization evidence."
			},
		]
		deniedLoads: [
			{
				path:                "cue/patterns/domain/source-code.cue"
				deniedBy:            "root-policy"
				rejectedRelationRef: "rel.keyword-relevance-authorizes-load"
				factRefs: [
					"root.file_loads_require_authorization_relation",
					"review.freeze_gate_rejects_relevance_only_loads",
				]
				reason:         "An arbitrary neighboring domain card is not authorized by the selected relation path."
				requestedBy:    "neighbor-discovery"
				classification: "architectural-drift"
			},
			{
				path:                "cue/patterns/**/*.cue"
				deniedBy:            "root-policy"
				rejectedRelationRef: "rel.go-enables-arbitrary-task-inference"
				factRefs: [
					"flow.infer_tasks_searches_arbitrary_data_and_may_be_spurious",
					"root.bounded_fallback_limits_loads_to_declared_surfaces",
				]
				reason:         "A broad discovery request is not a bounded selected-pattern or fallback authorization path."
				requestedBy:    "broad-discovery"
				classification: "architectural-drift"
			},
			{
				path:                "cue/patterns/projections/workflow-slice.cue"
				deniedBy:            "rejected-drift"
				rejectedRelationRef: "rel.keyword-relevance-authorizes-load"
				factRefs: [
					"root.file_loads_require_authorization_relation",
					"review.freeze_gate_rejects_relevance_only_loads",
				]
				reason:         "Keyword relevance alone does not authorize a load."
				requestedBy:    "keyword-relevance"
				classification: "architectural-drift"
			},
			{
				path:                "hidden/go-owned/load-policy"
				deniedBy:            "rejected-drift"
				rejectedRelationRef: "rel.go-owns-load-authorization"
				factRefs: [
					"contract.load_evidence_is_declared",
					"root.go_may_supply_taskfunc_and_runner_for_root_schema_tasks",
				]
				reason:         "The Go adapter may emit evidence but may not own hidden load authorization."
				requestedBy:    "go-cue-flow-adapter"
				classification: "architectural-drift"
			},
		]
	}

	bad: {
		selectedPatternIDs: []
		authorizationSource: "rejected-drift"
		rationale:           "Rejected evidence demonstrates that relevance and adapter-owned policy do not authorize file loads."
		relationRefs: [
			"rel.keyword-relevance-authorizes-load",
			"rel.go-owns-load-authorization",
		]
		factRefs: [
			"root.file_loads_require_authorization_relation",
			"review.freeze_gate_rejects_relevance_only_loads",
			"contract.load_evidence_is_declared",
		]
		loadedFiles: []
		deniedLoads: [
			{
				path:                "cue/patterns/domain/git.cue"
				deniedBy:            "rejected-drift"
				rejectedRelationRef: "rel.keyword-relevance-authorizes-load"
				factRefs: [
					"root.file_loads_require_authorization_relation",
					"review.freeze_gate_rejects_relevance_only_loads",
				]
				reason:         "A keyword hit does not provide a valid authorization relation."
				requestedBy:    "keyword-relevance"
				classification: "architectural-drift"
			},
			{
				path:                "go-adapter/internal/authorization-policy"
				deniedBy:            "rejected-drift"
				rejectedRelationRef: "rel.go-owns-load-authorization"
				factRefs: [
					"contract.load_evidence_is_declared",
					"flow.task_fill_fills_output_values_after_runner_execution",
				]
				reason:         "Go-owned hidden authorization is rejected; Go can emit evidence derived from contract schema only."
				requestedBy:    "go-cue-flow-adapter"
				classification: "architectural-drift"
			},
		]
	}

	fallback: {
		selectedPatternIDs: []
		authorizationSource: "bounded-fallback"
		rationale:           "Fallback mode is authorized only for explicit root-declared surfaces and still records relation and fact evidence."
		relationRefs: [
			"rel.bounded-fallback-admits-declared-surface",
			"rel.root-schema-declares-authorization-evidence",
		]
		factRefs: [
			"root.bounded_fallback_limits_loads_to_declared_surfaces",
			"root.file_loads_require_authorization_relation",
			"contract.load_evidence_is_declared",
		]
		loadedFiles: [
			{
				path:         "AGENTS.cue"
				authorizedBy: "bounded-fallback"
				relationRef:  "rel.bounded-fallback-admits-declared-surface"
				factRefs: [
					"root.bounded_fallback_limits_loads_to_declared_surfaces",
					"root.file_loads_require_authorization_relation",
				]
				reason: "Explicit AGENTS.cue surface is allowed under bounded fallback."
			},
			{
				path:         "cue/patterns/domain/schema.cue"
				authorizedBy: "bounded-fallback"
				relationRef:  "rel.bounded-fallback-admits-declared-surface"
				factRefs: [
					"root.bounded_fallback_limits_loads_to_declared_surfaces",
					"contract.load_evidence_is_declared",
				]
				reason: "The root-declared schema surface is allowed under bounded fallback."
			},
		]
		deniedLoads: [
			{
				path:                "cue/patterns/domain/chezmoi.cue"
				deniedBy:            "bounded-fallback"
				rejectedRelationRef: "rel.keyword-relevance-authorizes-load"
				factRefs: [
					"root.bounded_fallback_limits_loads_to_declared_surfaces",
					"review.freeze_gate_rejects_relevance_only_loads",
				]
				reason:         "Fallback does not expand to neighboring domain cards without an explicit root-declared surface relation."
				requestedBy:    "fallback-neighbor"
				classification: "architectural-drift"
			},
		]
	}
}
