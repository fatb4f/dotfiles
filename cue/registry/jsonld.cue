package registry

#JSONLDID: =~"^[a-zA-Z][a-zA-Z0-9_-]*:[A-Za-z0-9._/-]+$"

#RelevanceStatus: "eligible" | "rejected" | "uncertain"

#FindingJSONLD: {
	"@context"?: _
	"@id":       =~"^finding:[A-Za-z0-9._/-]+$"
	"@type":     "Finding"

	keywords?: [...string]
	supports?: [...string]

	source?: {
		path?: string
		span?: string
	}
}

#CandidateJSONLD: {
	"@context"?: _
	"@id":       #JSONLDID
	"@type":     "EntityCandidate" | "PatternCandidate"

	relevance: {
		status: #RelevanceStatus
		because?: [...=~"^finding:[A-Za-z0-9._/-]+$"]

		if status == "eligible" {
			because: [=~"^finding:[A-Za-z0-9._/-]+$", ...=~"^finding:[A-Za-z0-9._/-]+$"]
		}
	}
}

#RegistryRelevanceFrame: {
	"@context"?: _
	"@id":       =~"^registry:[A-Za-z0-9._/-]+$"
	"@type":     "RegistryRelevanceFrame"

	objective: string

	observes: [...#FindingJSONLD]

	candidates: [...#CandidateJSONLD]

	eligibleCandidates: [
		for candidate in candidates if candidate.relevance.status == "eligible" {
			candidate
		},
	]

	invariants: {
		isAuthority:        false
		authorizesLoads:    false
		authorizesMutation: false
	}
}
