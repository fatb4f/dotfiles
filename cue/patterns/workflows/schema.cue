package workflows

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
}

#WorkflowCardGateRequirement: {
	id:             string
	requiredBefore: "review" | "gate" | "eval" | "commit"
	proof:          string
}

#WorkflowCardSurface: {
	summary: string
	paths: [...string]
	commands?: [...string]
	authorities?: [...string]
}

#WorkflowCardScopes: {
	owned: [...string]
	adjacent: [...string]
	forbidden: [...string]
}

#WorkflowCardPattern: {
	id:     string
	domain: string

	surface: #WorkflowCardSurface
	scopes:  #WorkflowCardScopes

	knownGoodPatterns: [...#WorkflowGoodPattern]
	knownFailures: [...#WorkflowFailure]
	invariants: [...#WorkflowInvariant]
	gatePromotionRequirements: [...#WorkflowCardGateRequirement]
}

#WorkflowPattern: {
	id:      string
	domain:  string
	summary: string

	lifecycle: [...#WorkflowLifecycleLandmark]

	cards: {
		sourceCode: #WorkflowCardPattern
		shellWrap:  #WorkflowCardPattern
		cue:        #WorkflowCardPattern
		git:        #WorkflowCardPattern
	}

	edges: [...#WorkflowEdge]

	knownGoodPatterns: [...#WorkflowGoodPattern]
	knownFailures: [...#WorkflowFailure]
	invariants: [...#WorkflowInvariant]
	gatePromotionRequirements: [...#WorkflowGateRequirement]
}
