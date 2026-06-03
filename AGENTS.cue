package dotfiles

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

rootAgentContract: agentnode.#RootIndex & {
	schemaVersion: "agentNode.rootIndex.v1"

	schemaSource: agentnode.#RootSchemaSource

	root: {
		id:   "dotfiles-root"
		path: "."
	}

	contracts: [
		{
			nodeID: "workspace"
			path:   "nodes/workspace/AGENTS.cue"
			root:   "nodes/workspace"
		},
	]

	workspaceGraph: {
		root: "/home/_404/src"
		nodes: [
			{
				id:                "dotfiles"
				kind:              "repo"
				path:              "/home/_404/src/dotfiles"
				contract:          "/home/_404/src/dotfiles/AGENTS.cue"
				selectedByDefault: true
			},
			{
				id:       "git-mcp-go"
				kind:     "repo"
				path:     "/home/_404/src/git-mcp-go"
				contract: "/home/_404/src/git-mcp-go/AGENTS.cue"
			},
			{
				id:   "frame"
				kind: "repo"
				path: "/home/_404/src/frame"
			},
			{
				id:   ".agents"
				kind: "config-dir"
				path: "/home/_404/src/.agents"
			},
			{
				id:   ".codex"
				kind: "config-dir"
				path: "/home/_404/src/.codex"
			},
		]
		selectionCases: [
			{
				id:        "accept.git-mcp-go.worktree"
				objective: "Add git-mcp-go worktree support."
				selected:  "git-mcp-go"
				loadable: [
					"/home/_404/src/git-mcp-go/AGENTS.cue",
					"/home/_404/src/git-mcp-go/patterns/worktree.cue",
				]
				requires: {
					mcp: ["gopls.mcp"]
					validations: [
						"gopls.mcp go_workspace or go_file_context",
						"git status --short",
						"go test ./...",
					]
				}
				evidence: {
					rootMCPAvailable: true
					selectionMode:    "root-mediated"
					indexSources: [
						"/home/_404/src/dotfiles/AGENTS.cue",
					]
					selectedPatternIDs: ["git-mcp-go.worktree"]
					loadedFiles: [
						{
							path:         "/home/_404/src/dotfiles/AGENTS.cue"
							authorizedBy: "root-policy"
							reason:       "Root index supplied the workspace graph."
						},
						{
							path:            "/home/_404/src/git-mcp-go/AGENTS.cue"
							authorizedBy:    "selected-pattern"
							sourcePatternID: "git-mcp-go.worktree"
							reason:          "Workspace graph selected git-mcp-go as the target repository."
						},
						{
							path:            "/home/_404/src/git-mcp-go/patterns/worktree.cue"
							authorizedBy:    "selected-pattern"
							sourcePatternID: "git-mcp-go.worktree"
							reason:          "Selected git-mcp-go node owns its worktree pattern."
						},
					]
					deniedLoads: [
						{
							path:        "/home/_404/src/frame/**"
							reason:      "Sibling repo is not the selected workspace target."
							requestedBy: "sibling scan"
						},
						{
							path:        "/home/_404/src/.codex/**"
							reason:      "Config directory is not the selected workspace target."
							requestedBy: "sibling scan"
						},
						{
							path:        "/home/_404/src/.agents/**"
							reason:      "Config directory is not the selected workspace target."
							requestedBy: "sibling scan"
						},
						{
							path:        "/home/_404/src/* via unbounded scan"
							reason:      "Workspace graph selection is bounded to explicit nodes."
							requestedBy: "unbounded sibling scan"
						},
					]
					authorizationSource: "root-policy"
					rationale:           "The root workspace graph selected git-mcp-go for worktree support and denied all unselected siblings."
				}
			},
		]
		deniedCases: [
			{
				id:        "deny.frame"
				objective: "Inspect frame while git-mcp-go is selected."
				denied:    "frame"
				reason:    "frame is a known sibling but not the selected target."
				evidence:  workspaceGraph.selectionCases[0].evidence
			},
			{
				id:        "deny.codex"
				objective: "Inspect .codex while git-mcp-go is selected."
				denied:    ".codex"
				reason:    ".codex is a known config directory but not the selected target."
				evidence:  workspaceGraph.selectionCases[0].evidence
			},
			{
				id:        "deny.agents"
				objective: "Inspect .agents while git-mcp-go is selected."
				denied:    ".agents"
				reason:    ".agents is a known config directory but not the selected target."
				evidence:  workspaceGraph.selectionCases[0].evidence
			},
			{
				id:        "deny.unbounded-sibling-scan"
				objective: "Scan all siblings in the workspace."
				denied:    "/home/_404/src/*"
				reason:    "Sibling discovery must be selected by the workspace graph."
				evidence:  workspaceGraph.selectionCases[0].evidence
			},
		]
	}

	operations: [
		"agentnode.searchKeywords",
		"agentnode.selectPatterns",
		"agentnode.readSelectedPatterns",
		"agentnode.projectWorkflow",
	]
}

workspaceGraphFixture: agentnode.#WorkspaceGraph & rootAgentContract.workspaceGraph
