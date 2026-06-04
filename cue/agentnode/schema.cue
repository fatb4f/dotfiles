package agentnode

#RootSchemaSource: {
	package: *"github.com/fatb4f/dotfiles/cue/agentnode" | string
	version: *"agentNode.schema.v1" | string
}

#NodeRef: {
	id:                 string
	kind?:              string
	path:               string
	contract?:          string
	selectedByDefault?: bool
}

#LoadEvidence: {
	path:             string
	authorizedBy:     string
	sourcePatternID?: string
	reason?:          string
}

#DeniedLoad: {
	path:         string
	reason:       string
	requestedBy?: string
}

#WorkspaceSelectionEvidence: {
	rootMCPAvailable?: bool
	selectionMode?:    string
	indexSources?: [...string]
	selectedPatternIDs?: [...string]
	loadedFiles?: [...#LoadEvidence]
	deniedLoads?: [...#DeniedLoad]
	authorizationSource?: string
	rationale?:           string
}

#WorkspaceGraph: {
	root: string
	nodes: [...#NodeRef]
	selectionCases?: [...{
		id:         string
		objective?: string
		selected:   string
		loadable?: [...string]
		requires?: {
			mcp?: [...string]
			validations?: [...string]
		}
		evidence: #WorkspaceSelectionEvidence
	}]
	deniedCases?: [...{
		id:         string
		objective?: string
		denied:     string
		reason:     string
		evidence?:  #WorkspaceSelectionEvidence
	}]
}

#RootIndex: {
	schemaVersion: string
	schemaSource:  _
	root: {
		id:   string
		path: string
	}
	contracts?: [...{
		nodeID: string
		path:   string
		root?:  string
	}]
	workspaceGraph: #WorkspaceGraph
	operations?: [...string]
}

#GitMCPRepoAllowlistProjection: {
	sourceGraph:   string
	mcpServer:     string
	runtimeConfig: string
	argsFlag:      string
	graphRepoPaths: [...string]
	preservedRuntimeRepoPaths: [...string]
	repoPaths: [...string]
	policyBoundary: string
	evidence?:      #WorkspaceSelectionEvidence
}

#RuntimePreflightReport: {
	selectedRepoPath:                              string
	gitMCPAllowed:                                 bool
	goplsWorkspaceRoot:                            string
	goWorkspaceOK:                                 bool
	cueSelectedTargetMatchesToolRuntimeCapability: bool
	deniedSiblings?: [...#DeniedLoad]
	sessionBoundaryPrimitive?: string
	evidence?:                 #WorkspaceSelectionEvidence
}

#RALPHMCPSemanticTool: {
	canonical:         bool
	mode:              "read-only"
	policyAuthority:   "cue"
	adapterAuthority:  "runtime-containment"
	adapterOwnsPolicy: false
	lspSymbol:         string
}

#RALPHMCPSemanticBinding: {
	authorityPackage: string
	tools: [string]: #RALPHMCPSemanticTool
	deniedAuthoritySurfaces?: [...string]
	invariant: string
}
