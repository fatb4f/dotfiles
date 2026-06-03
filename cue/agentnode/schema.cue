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

		ownedFiles?: [...string]
		supportFiles?: [...string]

		forbiddenLoads: [...string]
	}

	workflow: {
		requires?: {
			skills?: [...string]
			validations?: [...string]
			fixtures?: [...string]
			projections?: [...string]
		}

		closeout?: [...string]
	}
}

#Keyword: {
	term:   string
	kind:   "primary" | "alias" | "tool" | "artifact" | "failure" | "domain"
	weight: int & >=1 & <=10
	mapsToPatterns: [...string]
}

#TaskPatternRef: {
	id:    string
	path:  string
	stage: "discover" | "plan" | "modify" | "verify" | "closeout"

	rationale?: string

	owns?: [...string]
	supports?: [...string]

	requires?: {
		skills?: [...string]
		validations?: [...string]
		fixtures?: [...string]
		projections?: [...string]
	}
}

#RootIndex: {
	schemaVersion: "agentNode.rootIndex.v1"

	schemaSource: #RootSchemaSource

	root: {
		id:   string
		path: string
	}

	contracts: [...#IndexedContract]
	workspaceGraph?: #WorkspaceGraph
	operations: [..."agentnode.searchKeywords" | "agentnode.selectPatterns" | "agentnode.readSelectedPatterns" | "agentnode.projectWorkflow"]
}

#IndexedContract: {
	nodeID: string
	path:   string
	root:   string
}

#WorkspaceNodeKind: "repo" | "config-dir"

#WorkspaceNode: {
	id:   string
	kind: #WorkspaceNodeKind
	path: string

	contract?:         string
	selectedByDefault: *false | bool
}

#WorkspaceSelectionCase: {
	id:        string
	objective: string
	selected:  string
	loadable: [...string]
	requires?: {
		mcp?: [...string]
		validations?: [...string]
	}
	evidence: #RootAuthorizationEvidence
}

#WorkspaceDeniedCase: {
	id:        string
	objective: string
	denied:    string
	reason:    string
	evidence:  #RootAuthorizationEvidence
}

#WorkspaceGraph: {
	root: string
	nodes: [...#WorkspaceNode]
	selectionCases: [...#WorkspaceSelectionCase]
	deniedCases: [...#WorkspaceDeniedCase]
}

#RootSchemaSource: {
	package: "github.com/fatb4f/dotfiles/cue/agentnode"
	path:    "cue/agentnode/schema.cue"
	role:    "root-cue-ssot"
}

#ComponentID: "root-cue-schema" | "root-agents-cue" | "workspace-agents-cue" | "workspace-projections-cue" | "workspace-pattern-card" | "go-cue-flow-adapter" | "cue-flow-engine" | "root-mcp" | "agent-prompt"

#FragmentKind: "root-index" | "agent-node-contract" | "task-pattern-card" | "selection-response" | "authorization-evidence" | "prompt-projection" | "interop-state" | "relation-edge"

#StateKind: "contract-state" | "projection-state" | "evidence-state" | "interop-state"

#PersistenceClass: "ephemeral" | "artifact-backed" | "committed" | "runtime-only" | "not-persisted"

#Operation: "defines" | "produces" | "consumes" | "validates" | "authorizes" | "emits-evidence" | "projects" | "adapts"

#FragmentContract: {
	name:            string
	kind:            #FragmentKind
	schema:          string
	schemaAuthority: "root-cue-schema"
	producedBy:      #ComponentID
	consumedBy?: [...#ComponentID]
	validatedBy: [...#ComponentID]
	authorizedBy?:    #ComponentID
	stateKind:        #StateKind
	persistenceClass: #PersistenceClass
}

#InteropState: {
	name:          string
	owner:         #ComponentID
	sourceOfTruth: #ComponentID
	readBy: [...#ComponentID]
	writtenBy: [...#ComponentID]
	validatedBy: [...#ComponentID]
	persistenceClass: #PersistenceClass
}

#RelationEdge: {
	from:      #ComponentID
	to:        #ComponentID
	artifact:  string
	operation: #Operation
	authority: #ComponentID
	stateKind: #StateKind
	allowed:   bool
	mustVet?: [...string]
	mustEmitEvidence?: bool
	rationale:         string
}

#AdmissibilityClassification: "admissible-fragment" | "architectural-drift" | "schema-gap" | "reject"

#AdmissibilityAssessment: {
	fragment:       string
	typeValid:      bool
	relationValid:  bool
	classification: #AdmissibilityClassification
	rationale:      string

	if typeValid == true && relationValid == true {
		classification: "admissible-fragment"
	}
	if typeValid == true && relationValid == false {
		classification: "architectural-drift"
	}
	if typeValid == false && relationValid == true {
		classification: "schema-gap"
	}
	if typeValid == false && relationValid == false {
		classification: "reject"
	}
}

#AuthorizationSource: "root-policy" | "selected-pattern" | "fallback-explicit-index"

#AuthorizedLoadedFile: {
	path:             string
	authorizedBy:     #AuthorizationSource
	sourcePatternID?: string
	reason:           string
}

#DeniedLoad: {
	path:         string
	reason:       string
	requestedBy?: string
}

#RootAuthorizationEvidence: {
	rootMCPAvailable: bool
	selectionMode:    "root-mediated" | "fallback-metadata" | "explicit-user-grant"
	indexSources: [...string]

	selectedPatternIDs: [...string]
	loadedFiles: [...#AuthorizedLoadedFile]
	deniedLoads?: [...#DeniedLoad]
	authorizationSource: #AuthorizationSource
	rationale:           string
}

#TaskPatternCard: {
	id: string

	authority: {
		loadableFiles: [...string]
	}

	workflow: {
		stage: "discover" | "plan" | "modify" | "verify" | "closeout"
	}
}

#RootSelectionResponse: {
	schemaVersion: "root.selectionResponse.v1"

	objective: string

	selected: [...{
		nodeID:    string
		patternID: string
		stage:     "discover" | "plan" | "modify" | "verify" | "closeout"
		rationale: string
		matchedTerms: [...string]

		rejectedTerms?: [...string]

		loadableFiles: [...string]
		supportFiles?: [...string]

		requires?: {
			skills?: [...string]
			validations?: [...string]
			fixtures?: [...string]
			projections?: [...string]
		}
	}]

	forbiddenLoads: [...string]

	evidence: #RootAuthorizationEvidence
}

#ProjectedPrompt: {
	schemaVersion: "agentNode.projectedPrompt.v1"
	text:          string
}

#RootContractCatalog: {
	schemaSource: #RootSchemaSource
	fragments: [...#FragmentContract]
	interopState: [...#InteropState]
	relations: [...#RelationEdge]
	admissibility: [...#AdmissibilityAssessment]
}
