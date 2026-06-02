package domain

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

	knownGoodPatterns: [...#PatternGoodPattern]
	knownFailures: [...#PatternFailure]
	invariants: [...#PatternInvariant]

	gatePromotionRequirements: [...#PatternGateRequirement]
}
