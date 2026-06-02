package agentnode

#AgentNode: {
	schemaVersion: "agentNode.v1"

	node: {
		id:     string
		domain: string
		root:   string
	}

	discovery: {
		keywords: [...#Keyword]
		aliases?: [string]: [...string]
		negative?: [...string]
	}

	authority: {
		taskPatterns: [...#TaskPatternRef]

		ownedFiles?:   [...string]
		supportFiles?: [...string]

		forbiddenLoads: [...string]
	}

	workflow: {
		requires?: {
			skills?:      [...string]
			validations?: [...string]
			fixtures?:    [...string]
			projections?: [...string]
		}

		closeout?: [...string]
	}
}

#Keyword: {
	term:           string
	kind:           "primary" | "alias" | "tool" | "artifact" | "failure" | "domain"
	weight:         int & >=1 & <=10
	mapsToPatterns: [...string]
}

#TaskPatternRef: {
	id:    string
	path:  string
	stage: "discover" | "plan" | "modify" | "verify" | "closeout"

	rationale?: string

	owns?:     [...string]
	supports?: [...string]

	requires?: {
		skills?:      [...string]
		validations?: [...string]
		fixtures?:    [...string]
		projections?: [...string]
	}
}

#RootIndex: {
	schemaVersion: "agentNode.rootIndex.v1"

	root: {
		id:   string
		path: string
	}

	contracts: [...#IndexedContract]
	operations: [..."agentnode.searchKeywords" | "agentnode.selectPatterns" | "agentnode.readSelectedPatterns" | "agentnode.projectWorkflow"]
}

#IndexedContract: {
	nodeID: string
	path:   string
	root:   string
}

#RootSelectionResponse: {
	schemaVersion: "root.selectionResponse.v1"

	objective: string

	selected: [...{
		nodeID:       string
		patternID:    string
		stage:        "discover" | "plan" | "modify" | "verify" | "closeout"
		rationale:    string
		matchedTerms: [...string]

		rejectedTerms?: [...string]

		loadableFiles: [...string]
		supportFiles?: [...string]

		requires?: {
			skills?:      [...string]
			validations?: [...string]
			fixtures?:    [...string]
			projections?: [...string]
		}
	}]

	forbiddenLoads: [...string]

	evidence: {
		rootMCPAvailable: bool
		selectionMode:    "root-mediated" | "fallback-metadata" | "explicit-user-grant"
		indexSources:     [...string]
	}
}

#ProjectedPrompt: {
	schemaVersion: "agentNode.projectedPrompt.v1"
	text:          string
}
