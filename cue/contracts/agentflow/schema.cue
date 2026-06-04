package agentflow

import (
	agentnode "github.com/fatb4f/dotfiles/cue/agentnode"
	domain "github.com/fatb4f/dotfiles/cue/patterns/domain"
)

#AgentFlowRun: {
	objective: string

	rootResponse: #RootResponse

	plan?:     #ExecutionPlan
	manifest?: #AgentFlowRunManifest

	diagnostics?: [string, ...string]
}

#RootResponse: {
	objective: string

	rootConsultation: {
		viaMCP:             bool
		objectivePresented: bool
		responseExported:   bool
		responseAccepted:   bool
	}

	privateResolutionEvidence: {
		downstreamResolvedByRoot:      bool
		workflowComposedOrAdopted:     bool
		promoGateRequirementsImported: bool
	}

	agentConsumable: {
		exposesDownstreamRegistry: bool
		selectedWorkflow?:         string
		executionEnvelope?:        _
		diagnostics?: [string, ...string]
	}

	audit: {
		directRegistryLoadsBeforeRootAcceptance: [...string]
		deniedDirectRegistryLoads: [...string]
	}

	// Optional adapter boundary hooks align this contract with existing root-response vocabulary.
	normalizedRootResponse?: domain.#NormalizedRootResponse
	runtimePreflight?:       agentnode.#RuntimePreflightReport
}

#AcceptedRootResponse: #RootResponse & {
	rootConsultation: {
		viaMCP:             true
		objectivePresented: true
		responseExported:   true
		responseAccepted:   true
	}

	privateResolutionEvidence: {
		downstreamResolvedByRoot:      true
		workflowComposedOrAdopted:     true
		promoGateRequirementsImported: true
	}

	agentConsumable: {
		exposesDownstreamRegistry: false
		selectedWorkflow:          string
		executionEnvelope:         _
	}

	audit: {
		directRegistryLoadsBeforeRootAcceptance: []
	}
}

#ExecutionPlan: {
	id:               string
	objective:        string
	selectedWorkflow: string

	nodes: [#DomainExecutionNode, ...#DomainExecutionNode]

	edges: [...{
		from: string
		to:   string
	}]

	derived?: {
		nodeOrder: [string, ...string]
		allNodesHavePromoGates:   bool
		allExecutedNodesAccepted: bool
		noMutatingNodeBeforeGate: bool
		promotionGateOutcomeRefs?: [...domain.#PromotionGateOutcome]
		authorizationEvidenceRefs?: [...domain.#AuthorizationEvidence]
	}
}

#AcceptedExecutionPlan: #ExecutionPlan & {
	nodes: [#AcceptedDomainNode, ...#AcceptedDomainNode]

	derived: {
		nodeOrder: [string, ...string]
		allNodesHavePromoGates:   true
		allExecutedNodesAccepted: true
		noMutatingNodeBeforeGate: true
	}
}

#DomainExecutionNode: {
	id:             string
	domain:         string
	objectiveSlice: string

	predecessors: [...string]

	mutationPolicy: "none" | "scoped"

	promoGate: {
		requirementsImported: bool
		source:               string
		evidencePath?:        string
		evidenceGenerated:    bool
		evidenceCueVetted:    bool
		valid:                bool
		outcome?:             domain.#PromotionGateOutcome
	}

	projection: {
		name?:                string
		exported:             bool
		accepted:             bool
		mutationScopeDerived: bool
		mutationScope: [...string]
	}

	firstMutation?: {
		path:      string
		line?:     int
		timestamp: string

		afterPromoGate:      bool
		afterProjection:     bool
		insideMutationScope: bool
	}

	validationEvidence: [...string]
	diagnostics?: [string, ...string]
}

#AcceptedReadOnlyDomainNode: #DomainExecutionNode & {
	mutationPolicy: "none"

	promoGate: {
		requirementsImported: true
		evidenceGenerated:    true
		evidenceCueVetted:    true
		valid:                true
	}

	projection: {
		mutationScopeDerived: false
		mutationScope: []
	}

	firstMutation?: _|_
}

#AcceptedMutatingDomainNode: #DomainExecutionNode & {
	mutationPolicy: "scoped"

	promoGate: {
		requirementsImported: true
		evidenceGenerated:    true
		evidenceCueVetted:    true
		valid:                true
	}

	projection: {
		exported:             true
		accepted:             true
		mutationScopeDerived: true
		mutationScope: [string, ...string]
	}

	firstMutation: {
		afterPromoGate:      true
		afterProjection:     true
		insideMutationScope: true
	}
}

#AcceptedDomainNode: #AcceptedReadOnlyDomainNode | #AcceptedMutatingDomainNode

#AcceptedAgentFlowRun: #AgentFlowRun & {
	rootResponse: #AcceptedRootResponse
	plan:         #AcceptedExecutionPlan
	manifest:     #AcceptedAgentFlowRunManifest

	diagnostics?: _|_
}

#PreMutationRejectedAgentFlowRun: #AgentFlowRun & {
	diagnostics: [string, ...string]

	plan?:     _|_
	manifest?: _|_
}

#PreMutationRejectedDomainNode: #DomainExecutionNode & {
	diagnostics: [string, ...string]

	projection: {
		mutationScopeDerived: false
		mutationScope: []
	}

	firstMutation?: _|_
}

#PostViolationAuditRejectedAgentFlowRun: #AgentFlowRun & {
	diagnostics: [string, ...string]

	plan?:     #ExecutionPlan
	manifest?: #AgentFlowRunManifest
}

#PostViolationAuditRejectedDomainNode: #DomainExecutionNode & {
	diagnostics: [string, ...string]

	firstMutation: {
		path: string
	}

	projection: {
		mutationScopeDerived: false
		mutationScope: []
	}
}

#RejectedPostMutationProjection: #PostViolationAuditRejectedDomainNode & {
	projection: {
		exported:             true
		accepted:             true
		mutationScopeDerived: false
		mutationScope: []
	}

	firstMutation: {
		afterProjection:     false
		insideMutationScope: false
	}
}

#RejectedScopeNotProjectionDerived: #PostViolationAuditRejectedDomainNode & {
	projection: {
		mutationScopeDerived: false
		mutationScope: []
	}

	firstMutation: {
		insideMutationScope: false
	}
}

#AgentFlowRunManifest: {
	runID:     string
	objective: string

	root: {
		consultedViaMCP:  bool
		responseAccepted: bool
	}

	plan: {
		id:               string
		selectedWorkflow: string
		nodeOrder: [string, ...string]
		edges: [...{
			from: string
			to:   string
		}]
	}

	domainNodes: [#DomainNodeManifest, ...#DomainNodeManifest]

	derived: {
		allPromoEvidenceCueVetted: bool
		allDomainNodesAccepted:    bool
		noMutatingNodeBeforeGate:  bool
	}

	closeout: {
		runManifestWritten:   bool
		runManifestCueVetted: bool
		validationCommands?: [...string]
		promoEvidenceSources?: [...string]
	}
}

#DomainNodeManifest: {
	id:             string
	domain:         string
	mutationPolicy: "none" | "scoped"

	promoGate: {
		requirementsImported: bool
		evidencePath:         string
		evidenceCueVetted:    bool
		valid:                bool
	}

	projection: {
		name?:                  string
		exportedBeforeMutation: bool
		acceptedBeforeMutation: bool
		mutationScopeDerived:   bool
	}

	firstMutation?: {
		path:                string
		afterPromoGate:      bool
		afterProjection:     bool
		insideMutationScope: bool
	}
}

#AcceptedReadOnlyDomainNodeManifest: #DomainNodeManifest & {
	mutationPolicy: "none"

	promoGate: {
		requirementsImported: true
		evidenceCueVetted:    true
		valid:                true
	}

	projection: {
		mutationScopeDerived: false
	}

	firstMutation?: _|_
}

#AcceptedMutatingDomainNodeManifest: #DomainNodeManifest & {
	mutationPolicy: "scoped"

	promoGate: {
		requirementsImported: true
		evidenceCueVetted:    true
		valid:                true
	}

	projection: {
		exportedBeforeMutation: true
		acceptedBeforeMutation: true
		mutationScopeDerived:   true
	}

	firstMutation: {
		afterPromoGate:      true
		afterProjection:     true
		insideMutationScope: true
	}
}

#AcceptedDomainNodeManifest: #AcceptedReadOnlyDomainNodeManifest | #AcceptedMutatingDomainNodeManifest

#AcceptedAgentFlowRunManifest: #AgentFlowRunManifest & {
	root: {
		consultedViaMCP:  true
		responseAccepted: true
	}

	domainNodes: [#AcceptedDomainNodeManifest, ...#AcceptedDomainNodeManifest]

	derived: {
		allPromoEvidenceCueVetted: true
		allDomainNodesAccepted:    true
		noMutatingNodeBeforeGate:  true
	}

	closeout: {
		runManifestWritten:   true
		runManifestCueVetted: true
	}
}
