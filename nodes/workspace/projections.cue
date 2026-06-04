package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

_workspaceIndexFile: "nodes/workspace/AGENTS.cue"

rootSelectionResponse: agentnode.#RootSelectionResponse & {
	schemaVersion: "root.selectionResponse.v1"

	objective: "Route workspace requests through AGENTS.cue contracts without broad filesystem discovery."

	selected: [
		{
			nodeID:    node.node.id
			patternID: "wezterm.workspace"
			stage:     "plan"
			rationale: node.authority.taskPatterns[0].rationale
			matchedTerms: ["workspace", "wezterm"]
			loadableFiles: [
				_workspaceIndexFile,
				node.authority.taskPatterns[0].path,
			]
			requires: node.authority.taskPatterns[0].requires
		},
		{
			nodeID:    node.node.id
			patternID: "nvim.smart-splits"
			stage:     "verify"
			rationale: node.authority.taskPatterns[1].rationale
			matchedTerms: ["workspace", "smart-splits"]
			loadableFiles: [
				_workspaceIndexFile,
				node.authority.taskPatterns[1].path,
			]
			requires: node.authority.taskPatterns[1].requires
		},
	]

	forbiddenLoads: node.authority.forbiddenLoads

	evidence: {
		rootMCPAvailable: true
		selectionMode:    "root-mediated"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
		authorizationSource: "root-policy"
		selectedPatternIDs: [
			node.authority.taskPatterns[0].id,
			node.authority.taskPatterns[1].id,
		]
		loadedFiles: [
			{
				path:         _workspaceIndexFile
				authorizedBy: "root-policy"
				reason:       "Root index selected the workspace AgentNode contract before task-owned files were loaded."
			},
			{
				path:            node.authority.taskPatterns[0].path
				authorizedBy:    "selected-pattern"
				sourcePatternID: node.authority.taskPatterns[0].id
				reason:          "Selected pattern metadata authorizes this pattern card."
			},
			{
				path:            node.authority.taskPatterns[1].path
				authorizedBy:    "selected-pattern"
				sourcePatternID: node.authority.taskPatterns[1].id
				reason:          "Selected pattern metadata authorizes this pattern card."
			},
		]
		deniedLoads: [
			{
				path:        "nodes/workspace/patterns/unselected_neighbor.cue"
				reason:      "Arbitrary neighboring files are not authorized by root selection or selected pattern metadata."
				requestedBy: "neighboring-file probe"
			},
			{
				path:        "** via unbounded rg --files"
				reason:      "Broad discovery requests are outside the root-mediated AgentNode contract."
				requestedBy: "broad discovery request"
			},
		]
		rationale: "Root policy selected workspace task patterns from declared AGENTS.cue metadata and limited loads to the root index plus selected pattern files."
	}
}

boundedDiscoveryFixture: rootSelectionResponse & {
	evidence: {
		selectionMode: "root-mediated"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
	}
	forbiddenLoads: [
		"chezmoi/**",
		"**/AGENTS.md recursive",
		"** via unbounded rg --files",
	]
}

fallbackDiscoveryFixture: agentnode.#RootSelectionResponse & {
	schemaVersion: "root.selectionResponse.v1"

	objective: "Route workspace requests through explicitly named index files only when root MCP selection is unavailable."

	selected: []

	forbiddenLoads: node.authority.forbiddenLoads

	evidence: {
		rootMCPAvailable: false
		selectionMode:    "fallback-metadata"
		indexSources: [
			"AGENTS.cue",
			_workspaceIndexFile,
		]
		authorizationSource: "fallback-explicit-index"
		selectedPatternIDs: []
		loadedFiles: [
			{
				path:         "AGENTS.cue"
				authorizedBy: "fallback-explicit-index"
				reason:       "Fallback mode permits only explicitly named root index files when root MCP selection is unavailable."
			},
			{
				path:         _workspaceIndexFile
				authorizedBy: "fallback-explicit-index"
				reason:       "Fallback mode permits only explicitly named node index files when root MCP selection is unavailable."
			},
		]
		deniedLoads: [
			{
				path:        "nodes/workspace/patterns/wezterm_workspace.cue"
				reason:      "Fallback explicit-index mode does not authorize task pattern files without root mediation or user grant."
				requestedBy: "fallback pattern-file probe"
			},
			{
				path:        "** via unbounded rg --files"
				reason:      "Fallback mode remains bounded and denies broad discovery requests."
				requestedBy: "broad discovery request"
			},
		]
		rationale: "Root MCP selection is unavailable, so fallback evidence is limited to explicitly named index files and denial records."
	}
}

rootSchemaDerivedFixture: agentnode.#RootContractCatalog & {
	schemaSource: agentnode.#RootSchemaSource

	fragments: [
		{
			name:            "rootAgentContract"
			kind:            "root-index"
			schema:          "agentnode.#RootIndex"
			schemaAuthority: "root-cue-schema"
			producedBy:      "root-agents-cue"
			consumedBy: ["root-mcp", "go-cue-adapter"]
			validatedBy: ["root-cue-schema"]
			authorizedBy:     "root-cue-schema"
			stateKind:        "contract-state"
			persistenceClass: "committed"
		},
		{
			name:            "workspace.node"
			kind:            "agent-node-contract"
			schema:          "agentnode.#AgentNode"
			schemaAuthority: "root-cue-schema"
			producedBy:      "workspace-agents-cue"
			consumedBy: ["root-mcp", "go-cue-adapter"]
			validatedBy: ["root-cue-schema"]
			authorizedBy:     "root-cue-schema"
			stateKind:        "contract-state"
			persistenceClass: "committed"
		},
		{
			name:            "workspace.rootSelectionResponse"
			kind:            "selection-response"
			schema:          "agentnode.#RootSelectionResponse"
			schemaAuthority: "root-cue-schema"
			producedBy:      "workspace-projections-cue"
			consumedBy: ["go-cue-adapter", "agent-prompt"]
			validatedBy: ["root-cue-schema"]
			authorizedBy:     "root-mcp"
			stateKind:        "projection-state"
			persistenceClass: "artifact-backed"
		},
		{
			name:            "workspace.rootSelectionResponse.evidence"
			kind:            "authorization-evidence"
			schema:          "agentnode.#RootAuthorizationEvidence"
			schemaAuthority: "root-cue-schema"
			producedBy:      "workspace-projections-cue"
			consumedBy: ["root-mcp", "go-cue-adapter", "agent-prompt"]
			validatedBy: ["root-cue-schema"]
			authorizedBy:     "root-cue-schema"
			stateKind:        "evidence-state"
			persistenceClass: "artifact-backed"
		},
		{
			name:            "workspace.projectedPrompt"
			kind:            "prompt-projection"
			schema:          "agentnode.#ProjectedPrompt"
			schemaAuthority: "root-cue-schema"
			producedBy:      "workspace-projections-cue"
			consumedBy: ["agent-prompt"]
			validatedBy: ["root-cue-schema"]
			authorizedBy:     "root-cue-schema"
			stateKind:        "projection-state"
			persistenceClass: "artifact-backed"
		},
	]

	interopState: [
		{
			name:          "root selection response"
			owner:         "root-cue-schema"
			sourceOfTruth: "root-cue-schema"
			readBy: ["root-mcp", "go-cue-adapter", "agent-prompt"]
			writtenBy: ["workspace-projections-cue"]
			validatedBy: ["root-cue-schema"]
			persistenceClass: "artifact-backed"
		},
		{
			name:          "cue flow adapter load observation"
			owner:         "go-cue-adapter"
			sourceOfTruth: "root-cue-schema"
			readBy: ["root-mcp", "agent-prompt"]
			writtenBy: ["go-cue-adapter"]
			validatedBy: ["root-cue-schema"]
			persistenceClass: "runtime-only"
		},
		{
			name:          "cue flow execution state"
			owner:         "cuelang-flow-runtime"
			sourceOfTruth: "root-cue-schema"
			readBy: ["go-cue-adapter"]
			writtenBy: ["cuelang-flow-runtime"]
			validatedBy: ["root-cue-schema"]
			persistenceClass: "runtime-only"
		},
	]

	relations: [
		{
			from:      "workspace-agents-cue"
			to:        "go-cue-adapter"
			artifact:  "workspace.node"
			operation: "consumes"
			authority: "root-cue-schema"
			stateKind: "contract-state"
			allowed:   true
			mustVet: [
				"cue vet ./cue/agentnode/...",
				"cue vet ./nodes/workspace/...",
			]
			rationale: "The Go CUE flow adapter may consume workspace contracts only after they conform to the root AgentNode schema."
		},
		{
			from:             "go-cue-adapter"
			to:               "workspace-projections-cue"
			artifact:         "workspace.rootSelectionResponse.evidence"
			operation:        "emits-evidence"
			authority:        "root-cue-schema"
			stateKind:        "evidence-state"
			allowed:          true
			mustEmitEvidence: true
			mustVet: [
				"cue vet ./cue/agentnode/...",
				"cue vet ./nodes/workspace/...",
			]
			rationale: "The Go CUE flow adapter may emit runtime observations only as root-shaped authorization evidence."
		},
		{
			from:      "go-cue-adapter"
			to:        "cuelang-flow-runtime"
			artifact:  "cuelang.org/go/tools/flow"
			operation: "adapts"
			authority: "root-cue-schema"
			stateKind: "interop-state"
			allowed:   true
			mustVet: [
				"cue vet ./cue/agentnode/...",
				"cue vet ./nodes/workspace/...",
			]
			rationale: "The planned Go API layer adapts the CUE flow engine and must execute root-declared transitions rather than invent policy."
		},
		{
			from:             "root-mcp"
			to:               "workspace-projections-cue"
			artifact:         "workspace.rootSelectionResponse.evidence"
			operation:        "authorizes"
			authority:        "root-cue-schema"
			stateKind:        "evidence-state"
			allowed:          true
			mustEmitEvidence: true
			rationale:        "Root policy may authorize selected loads when evidence is typed by the root schema."
		},
		{
			from:      "workspace-projections-cue"
			to:        "agent-prompt"
			artifact:  "workspace.projectedPrompt"
			operation: "projects"
			authority: "root-cue-schema"
			stateKind: "projection-state"
			allowed:   true
			rationale: "Agent prompts consume bounded projections derived from root-shaped CUE contracts."
		},
		{
			from:      "go-cue-adapter"
			to:        "workspace-projections-cue"
			artifact:  "hidden-go-policy"
			operation: "authorizes"
			authority: "go-cue-adapter"
			stateKind: "contract-state"
			allowed:   false
			rationale: "Go adapter-owned policy is architectural drift because policy authority must remain in the root CUE schema."
		},
	]

	admissibility: [
		{
			fragment:      "workspace.node"
			typeValid:     true
			relationValid: true
			rationale:     "The workspace AGENTS.cue fragment conforms to agentnode.#AgentNode and has an allowed CUE-to-Go-flow-adapter consumer relation."
		},
		{
			fragment:      "hidden-go-policy"
			typeValid:     true
			relationValid: false
			rationale:     "A Go adapter-owned policy fragment may be well-shaped but is drift because relation authority is not root CUE."
		},
		{
			fragment:      "untyped-runtime-intention"
			typeValid:     false
			relationValid: true
			rationale:     "A valid runtime intention without a root-owned type contract is a schema gap."
		},
		{
			fragment:      "untyped-go-policy"
			typeValid:     false
			relationValid: false
			rationale:     "An untyped fragment with an invalid Go adapter-owned policy relation is rejected."
		},
	]
}

projectedPrompt: agentnode.#ProjectedPrompt & {
	schemaVersion: "agentNode.projectedPrompt.v1"
	text: """
		Use AGENTS.cue/root MCP selections as the machine-readable authority.
		AGENTS.md is narrative guidance only.
		Do not inspect task-owned files until root mediation selects a task pattern.
		If root MCP is unavailable, use only explicitly named AGENTS.cue/index files or user-granted paths.
		Record selected patterns, loaded files, rationale, and fallback mode.
		"""
}
