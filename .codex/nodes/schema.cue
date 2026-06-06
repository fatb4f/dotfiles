package nodes

#LocalNodeKind: "node" | "pattern" | "projection" | "surface"

#RetrievalStage: "retrieve" | "plan" | "verify" | "assemble" | "legitimize" | "perform" | "harden"

#LocalNodeContext: close({
	id:         string
	role:       "local-node-context"
	sourcePath: string

	domain?: string
	kind:    #LocalNodeKind

	surfaces?: [...close({
		id:       string
		path:     string
		function: string
	})]

	retrievalHints?: close({
		matchedTerms?:  [...string]
		relevantFiles?: [...string]
		patternIDs?:    [...string]
		stage?:         #RetrievalStage
	})

	negativeAuthority: close({
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	})

	provenance: close({
		generatedBy:    "R"
		sourceObserved: string
		manifestID:     string
		head?:          string
	})

	policy?:                _|_
	globalInvariant?:       _|_
	authority?:             _|_
	loadAdmissibility?:     _|_
	mutationAdmissibility?: _|_
	executionPermission?:   _|_
	reusablePolicy?:        _|_
	rootAuthority?:         _|_
})
