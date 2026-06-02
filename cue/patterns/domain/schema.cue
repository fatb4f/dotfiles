package domain

#DomainNodePattern: {
	id:     string
	domain: string

	surface: string
	scopes: [...string]

	knownGoodPatterns: [...string]
	knownFailures: [...string]
	invariants: [...string]

	gatePromotionRequirements: [...string]
}
