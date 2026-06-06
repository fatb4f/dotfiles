package adapter

gitMCPGoExtraction: #AdapterExtraction & {
	id:            "git-mcp-go.cue-adapter"
	sourceRepo:    "/home/_404/src/git-mcp-go"
	destination:   "cue/adapter"
	sourcePackage: "github.com/geropl/git-mcp-go/pkg"

	tools: [
		{
			name:        "cue_eval"
			description: "Evaluates CUE from an allowed repository without shelling out to the cue CLI"
			mode:        "read-only"
			handler:     "cueEvalHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed Git repository"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
				{name: "path", type: "string", description: "CUE path to evaluate, for example rootAgentContract.workspaceGraph"},
				{name: "concrete", type: "boolean", description: "Require the evaluated value to be concrete"},
			]
		},
		{
			name:        "cue_validate"
			description: "Validates CUE package constraints from an allowed repository"
			mode:        "read-only"
			handler:     "cueValidateHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed Git repository"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
				{name: "path", type: "string", description: "Optional CUE path to validate"},
				{name: "concrete", type: "boolean", description: "Require the validated value to be concrete"},
			]
		},
		{
			name:        "ralph_runtime_preflight"
			description: "Evaluates the RALPH runtime preflight fixture from the repository CUE contract"
			mode:        "read-only"
			handler:     "ralphRuntimePreflightHandler"
			projection:  "runtimePreflightFixture"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed repository containing AGENTS.cue"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
			]
		},
		{
			name:        "ralph_git_mcp_allowlist"
			description: "Evaluates the RALPH Git MCP repository allowlist projection from the CUE contract"
			mode:        "read-only"
			handler:     "ralphGitMCPAllowlistHandler"
			projection:  "gitMCPRepoAllowlistFixture"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed repository containing AGENTS.cue"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
			]
		},
		{
			name:        "cue_symbol_resolve"
			description: "Resolves a CUE symbol from an allowed repository as semantic evidence only"
			mode:        "read-only"
			handler:     "cueSymbolResolveHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed Git repository"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
				{name: "symbol", type: "string", required: true, description: "Canonical CUE symbol path to resolve"},
			]
		},
		{
			name:        "cue_symbol_references"
			description: "Finds textual CUE references for a symbol inside an allowed package as semantic evidence only"
			mode:        "read-only"
			handler:     "cueSymbolReferencesHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed Git repository"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
				{name: "symbol", type: "string", required: true, description: "Canonical CUE symbol path to find"},
			]
		},
		{
			name:        "cue_diagnostics"
			description: "Runs CUE package diagnostics from an allowed repository as semantic evidence only"
			mode:        "read-only"
			handler:     "cueDiagnosticsHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed Git repository"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
			]
		},
		{
			name:        "ralph_surface_resolve"
			description: "Resolves a RALPH/CUE MCP surface to its canonical CUE binding as semantic evidence only"
			mode:        "read-only"
			handler:     "ralphSurfaceResolveHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed repository containing AGENTS.cue"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
				{name: "surface", type: "string", required: true, description: "RALPH/CUE MCP surface name"},
			]
		},
		{
			name:        "ralph_surface_preflight"
			description: "Checks registered and setup-approved RALPH/CUE surfaces against canonical CUE bindings as semantic evidence only"
			mode:        "read-only"
			handler:     "ralphSurfacePreflightHandler"
			arguments: [
				{name: "repo_path", type: "string", required: true, description: "Path to allowed repository containing AGENTS.cue"},
				{name: "package_dir", type: "string", description: "Package directory relative to repo_path (default: .)"},
			]
		},
	]

	ralphMCPBinding: {
		authorityPackage: "root.AGENTS"
		tools: {
			cue_eval: {
				name: "cue_eval"
			}
			cue_validate: {
				name: "cue_validate"
			}
			cue_symbol_resolve: {
				name: "cue_symbol_resolve"
			}
			cue_symbol_references: {
				name: "cue_symbol_references"
			}
			cue_diagnostics: {
				name: "cue_diagnostics"
			}
			ralph_runtime_preflight: {
				name: "ralph_runtime_preflight"
			}
			ralph_git_mcp_allowlist: {
				name: "ralph_git_mcp_allowlist"
			}
			ralph_surface_resolve: {
				name: "ralph_surface_resolve"
			}
			ralph_surface_preflight: {
				name: "ralph_surface_preflight"
			}
		}
		deniedAuthoritySurfaces: ["cue-flow", "cueFlowLoopContract"]
		invariant: "semantic resolution is evidence only"
	}

	runtimeProjections: {
		runtimePreflight: "runtimePreflightFixture"
		gitMCPAllowlist:  "gitMCPRepoAllowlistFixture"
	}

	sourceEvidence: [
		{path: "/home/_404/src/git-mcp-go/pkg/cue_adapter.go", role: "MCP CUE tool registration and CUE evaluation adapter"},
		{path: "/home/_404/src/git-mcp-go/pkg/cue_semantic_gate.go", role: "semantic evidence and RALPH surface preflight adapter"},
		{path: "/home/_404/src/git-mcp-go/pkg/cue_adapter_test.go", role: "fixture source for RALPH MCP binding and projection behavior"},
		{path: "/home/_404/src/git-mcp-go/AGENTS.cue", role: "source repository node contract"},
		{path: "/home/_404/src/git-mcp-go/patterns/worktree.cue", role: "source repository worktree pattern"},
	]
}
