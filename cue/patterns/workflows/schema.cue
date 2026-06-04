package workflows

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#WorkflowLifecycleLandmark: "start" | "review" | "gate" | "eval"

#WorkflowNodeID: "source-code" | "shell-wrap" | "cue" | "git"

#WorkflowEdge: {
	id:      string
	from:    #WorkflowNodeID
	to:      #WorkflowNodeID
	summary: string
}

#WorkflowGoodPattern: {
	id:      string
	summary: string
}

#WorkflowFailure: {
	id:        string
	symptom:   string
	avoidance: string
}

#WorkflowInvariant: {
	id:       string
	mustHold: string
}

#WorkflowGateRequirement: {
	id:             string
	requiredBefore: #WorkflowLifecycleLandmark
	proof:          string
	factRefs:       domain.#FactRefList
}

#EntityProjection:   domain.#EntityProjection
#PatternGoodPattern: domain.#PatternGoodPattern
#PatternFailure:     domain.#PatternFailure
#PatternInvariant:   domain.#PatternInvariant

#WorkflowPattern: {
	id:      string
	area:    "workflow"
	summary: string

	lifecycle: [...#WorkflowLifecycleLandmark]

	cards: {
		sourceCode: #EntityProjection
		shellWrap:  #EntityProjection
		cue:        #EntityProjection
		git:        #EntityProjection
	}

	edges: [...#WorkflowEdge]

	knownGoodPatterns: [...#PatternGoodPattern]
	knownFailures: [...#PatternFailure]
	invariants: [...#PatternInvariant]
	gatePromotionRequirements: [...#WorkflowGateRequirement]
}
