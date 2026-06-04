package contracts

#SurfaceKind:
	"contracts" |
	"nodes" |
	"patterns" |
	"registry" |
	"flow" |
	"lifecycle" |
	"adapters"

#AuthorityMode:
	"agent-binding" |
	"classification" |
	"projection" |
	"interface" |
	"fsm-composition" |
	"evidence" |
	"transport"

#SurfaceBoundary: {
	kind: #SurfaceKind
	path: string
	mode: #AuthorityMode

	bindsAgent:                    bool
	ownsPolicy:                    bool
	ownsInvariants:                bool
	mayGrantLoadAdmissibility:     bool
	mayGrantMutationAdmissibility: bool

	description: string
}

#ArchitectureContract: {
	schemaVersion: *"dotfiles.cue.architectureFoundation.v1" | string

	contracts: {
		bindAgent:                     true
		ownPolicy:                     true
		ownInvariants:                 true
		mayGrantLoadAdmissibility:     true
		mayGrantMutationAdmissibility: true
		onlyThroughAcceptedGates:      true
		rootSchemaVetPromo:            true
	}

	nodes: {
		areEntities:                   true
		mayClassifyEntities:           true
		areAuthority:                  false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		ownPatterns:                   false
		managePatterns:                false
	}

	patterns: {
		areTaskCentricSkillProjections: true
		areCanonicalPatternLayer:       true
		replaceNodeManagedPatterns:     true
		bindDomainsAsClassification:    true
		areAuthority:                   false
		mayReferenceNodes:              true
		mayReferenceContracts:          true
		mayGrantLoadAdmissibility:      false
		mayGrantMutationAdmissibility:  false
	}

	registry: {
		isPatternInterface:            true
		isAuthority:                   false
		bindsAgent:                    false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		returnsPatternRefs:            true
		authorizesBehavior:            false
	}

	flow: {
		ownsFSM:                       true
		composesContracts:             true
		assemblesContractCandidates:   true
		vetsSelectedBundle:            true
		mayVetContractCandidates:      true
		bindsAgent:                    false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
	}

	lifecycle: {
		recordsEvidence: true
		isAuthority:     false
	}

	adapters: {
		areAuthority:                  false
		ownPolicy:                     false
		mcpIsTransportOnly:            true
		runProjectObserveOnly:         true
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
	}

	mcp: {
		isAccessBoundary:         true
		isTransportOnly:          true
		doesNotAuthorizeMutation: true
	}

	gitMutation: {
		requiresAcceptedContract:      true
		requiresRootSchemaVettedPromo: true
	}

	dependencies: {
		nodes: {
			mayClassifyEntities: true
			ownPatterns:         false
			managePatterns:      false
		}
		patterns: {
			mayReferenceNodes:     true
			mayReferenceContracts: true
		}
		registry: {
			mayReturnPatternRefs: true
			authorizesBehavior:   false
		}
		flow: {
			mayComposeContractCandidates: true
			mayVetContractCandidates:     true
		}
		contracts: {
			bindAgent:                     true
			mayGrantLoadAdmissibility:     true
			mayGrantMutationAdmissibility: true
			onlyThroughAcceptedGates:      true
		}
		adapters: {
			runProjectObserveOnly:         true
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
		}
	}
}

#SSOTVocabularyAssessment: {
	status: "pass" | "fail" | "drift"

	allowedSurfaces: [...string]
	checkedSurfaces: [...string]
	terms: [...string]

	drift: [...{
		path:   string
		term:   string
		status: "accepted" | "drift"
	}]

	if status == "pass" {
		drift: []
	}
}

ssotVocabularyAssessment: #SSOTVocabularyAssessment & {
	status: "pass"

	allowedSurfaces: [
		"AGENTS.cue",
		"cue/contracts/architecture.cue",
		"cue/contracts/schema.cue",
		"cue/contracts/**",
	]

	checkedSurfaces: [
		"cue/patterns/domain/schema.cue",
		"cue/patterns/domain/*.cue",
		"cue/patterns/projections/*.cue",
		"cue/nodes/**",
		"cue/registry/**",
		"cue/flow/**",
	]

	terms: [
		"authorityPaths",
		"root-owned",
		"root.authorization",
		"root-policy-authorizes",
		"selected-pattern-authorizes",
		"bounded-fallback-authorizes",
		"#DomainNodePattern",
		"domain: \"cue\"",
		"discovery.entrypoints",
		"discovery.requiredLoads",
	]

	drift: []
}

#ArchitectureFoundation: {
	layout: {
		root: "cue"
		directories: {
			contracts: "cue/contracts"
			nodes:     "cue/nodes"
			patterns:  "cue/patterns"
			registry:  "cue/registry"
			flow:      "cue/flow"
			adapters:  "cue/adapters"
		}
	}

	surfaces: {
		contracts: #SurfaceBoundary & {
			kind:                          "contracts"
			path:                          "cue/contracts"
			mode:                          "agent-binding"
			bindsAgent:                    true
			ownsPolicy:                    true
			ownsInvariants:                true
			mayGrantLoadAdmissibility:     true
			mayGrantMutationAdmissibility: true
			description:                   "agent-binding contracts, invariants, accepted gates, and admissibility rules"
		}

		nodes: #SurfaceBoundary & {
			kind:                          "nodes"
			path:                          "cue/nodes"
			mode:                          "classification"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "repo-local entity classification records"
		}

		patterns: #SurfaceBoundary & {
			kind:                          "patterns"
			path:                          "cue/patterns"
			mode:                          "projection"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "task-centric projections that may reference nodes and contracts"
		}

		registry: #SurfaceBoundary & {
			kind:                          "registry"
			path:                          "cue/registry"
			mode:                          "interface"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "interface that returns pattern references without authorizing behavior"
		}

		flow: #SurfaceBoundary & {
			kind:                          "flow"
			path:                          "cue/flow"
			mode:                          "fsm-composition"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "CUE-flow FSM that composes and vets contract candidates"
		}

		lifecycle: #SurfaceBoundary & {
			kind:                          "lifecycle"
			path:                          "cue/contracts/lifecycle"
			mode:                          "evidence"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "run proof, closeout evidence, and process evidence schema"
		}

		adapters: #SurfaceBoundary & {
			kind:                          "adapters"
			path:                          "cue/adapters"
			mode:                          "transport"
			bindsAgent:                    false
			ownsPolicy:                    false
			ownsInvariants:                false
			mayGrantLoadAdmissibility:     false
			mayGrantMutationAdmissibility: false
			description:                   "MCP, Hookrail, and runtime adapter contracts that run, project, or observe"
		}
	}

	invariants: #ArchitectureContract
}

architecture:           #ArchitectureContract
architectureFoundation: #ArchitectureFoundation
