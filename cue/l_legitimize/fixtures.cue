package l_legitimize

import "list"

_baseLoadedContext: #LoadedContext & {
	id: "loadedContext.good"
	taskGraphContract: {id: "taskGraph.good"}
	taskGraphContractAccepted: true
	cueDeclaredSurfaces: [
		{id: "cue_eval", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "cue_validate", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "ralph_runtime_preflight", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "ralph_git_mcp_allowlist", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "cue_symbol_resolve", kind: "semantic-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "cue_symbol_references", kind: "semantic-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "cue_diagnostics", kind: "semantic-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "ralph_surface_resolve", kind: "semantic-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "ralph_surface_preflight", kind: "semantic-tool", authorityOwner: "cue", requiresMCPRegistration: true},
		{id: "root.AGENTS", kind: "root-schema", authorityOwner: "cue"},
		{id: "cue.a_assemble", kind: "leaf-schema", authorityOwner: "cue"},
	]
	semanticResolvedSurfaces: [
		{id: "semantic.cue_eval", cueSurface: "cue_eval"},
		{id: "semantic.cue_validate", cueSurface: "cue_validate"},
		{id: "semantic.ralph_runtime_preflight", cueSurface: "ralph_runtime_preflight"},
		{id: "semantic.ralph_git_mcp_allowlist", cueSurface: "ralph_git_mcp_allowlist"},
		{id: "semantic.cue_symbol_resolve", cueSurface: "cue_symbol_resolve"},
		{id: "semantic.cue_symbol_references", cueSurface: "cue_symbol_references"},
		{id: "semantic.cue_diagnostics", cueSurface: "cue_diagnostics"},
		{id: "semantic.ralph_surface_resolve", cueSurface: "ralph_surface_resolve"},
		{id: "semantic.ralph_surface_preflight", cueSurface: "ralph_surface_preflight"},
	]
	mcpRegisteredSurfaces: [
		{id: "mcp.cue_eval", cueSurface: "cue_eval"},
		{id: "mcp.cue_validate", cueSurface: "cue_validate"},
		{id: "mcp.ralph_runtime_preflight", cueSurface: "ralph_runtime_preflight"},
		{id: "mcp.ralph_git_mcp_allowlist", cueSurface: "ralph_git_mcp_allowlist"},
		{id: "mcp.cue_symbol_resolve", cueSurface: "cue_symbol_resolve"},
		{id: "mcp.cue_symbol_references", cueSurface: "cue_symbol_references"},
		{id: "mcp.cue_diagnostics", cueSurface: "cue_diagnostics"},
		{id: "mcp.ralph_surface_resolve", cueSurface: "ralph_surface_resolve"},
		{id: "mcp.ralph_surface_preflight", cueSurface: "ralph_surface_preflight"},
	]
	setupAllowedSurfaces: [
		{id: "setup.cue_eval", cueSurface: "cue_eval"},
		{id: "setup.cue_validate", cueSurface: "cue_validate"},
		{id: "setup.ralph_runtime_preflight", cueSurface: "ralph_runtime_preflight"},
		{id: "setup.ralph_git_mcp_allowlist", cueSurface: "ralph_git_mcp_allowlist"},
		{id: "setup.cue_symbol_resolve", cueSurface: "cue_symbol_resolve"},
		{id: "setup.cue_symbol_references", cueSurface: "cue_symbol_references"},
		{id: "setup.cue_diagnostics", cueSurface: "cue_diagnostics"},
		{id: "setup.ralph_surface_resolve", cueSurface: "ralph_surface_resolve"},
		{id: "setup.ralph_surface_preflight", cueSurface: "ralph_surface_preflight"},
	]
	instructionReferencedSurfaces: [
		{id: "instruction.cue_eval", cueSurface: "cue_eval"},
		{id: "instruction.cue_validate", cueSurface: "cue_validate"},
		{id: "instruction.ralph_runtime_preflight", cueSurface: "ralph_runtime_preflight"},
		{id: "instruction.ralph_git_mcp_allowlist", cueSurface: "ralph_git_mcp_allowlist"},
		{id: "instruction.cue_symbol_resolve", cueSurface: "cue_symbol_resolve"},
		{id: "instruction.cue_symbol_references", cueSurface: "cue_symbol_references"},
		{id: "instruction.cue_diagnostics", cueSurface: "cue_diagnostics"},
		{id: "instruction.ralph_surface_resolve", cueSurface: "ralph_surface_resolve"},
		{id: "instruction.ralph_surface_preflight", cueSurface: "ralph_surface_preflight"},
	]
	loadedFiles: [
		{path: "/home/_404/src/dotfiles/AGENTS.cue", authorizedBy: "selected-node"},
		{path: "/home/_404/src/dotfiles/cue/a_assemble/contract.cue", authorizedBy: "selected-pattern"},
		{path: "/home/_404/src/dotfiles/cue/l_legitimize/contract.cue", authorizedBy: "selected-pattern"},
	]
	deniedLoads: [
		{path: "/home/_404/src/frame/**", reason: "Sibling repo is not selected."},
		{path: "/home/_404/src/git-mcp-go/**", reason: "Sibling repo is not needed for this lifecycle change."},
		{path: "/home/_404/src/* via unbounded scan", reason: "Workspace graph selection must be explicit."},
	]
	rootSchema: {id: "root.AGENTS", path: "/home/_404/src/dotfiles/AGENTS.cue", loaded: true, authorityOwner: "cue"}
	vettedLeafSchemas: [
		{id: "cue.a_assemble", path: "/home/_404/src/dotfiles/cue/a_assemble/contract.cue", loaded: true, vetted: true, authorityOwner: "cue"},
	]
	adapterPolicyOwnershipClaims: []
	semanticPolicyOwnershipClaims: []
	legacyAuthorityTerms: []
	unboundedRepoScansAdmitted: false
	deniedSiblingLoadsLoadable: false
	cueOwnsPolicy:              true
	adapterOwnsPolicy:          false
}

goodLoad: #LoadPhase & {
	input: {taskGraphContract: {id: "taskGraph.good"}, taskGraphContractAccepted: true}
	output: _baseLoadedContext
}

negativeMCPToolRegisteredNotDeclared: {
	mcpRegisteredSurfaces: list.Concat([_baseLoadedContext.mcpRegisteredSurfaces, [{id: "mcp.undeclared", cueSurface: "undeclared_tool"}]])
}

negativeCueSurfaceMissingRequiredMCP: {
	cueDeclaredSurfaces: list.Concat([_baseLoadedContext.cueDeclaredSurfaces, [{id: "required_missing_mcp", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true}]])
}

negativeSetupToolNotDeclared: {
	setupAllowedSurfaces: list.Concat([_baseLoadedContext.setupAllowedSurfaces, [{id: "setup.undeclared", cueSurface: "undeclared_tool"}]])
}

negativeInstructionSurfaceNotDeclared: {
	instructionReferencedSurfaces: list.Concat([_baseLoadedContext.instructionReferencedSurfaces, [{id: "instruction.undeclared", cueSurface: "undeclared_surface"}]])
}

negativeSemanticClaimsAuthorization: {
	semanticResolvedSurfaces: list.Concat([_baseLoadedContext.semanticResolvedSurfaces, [{id: "semantic.auth.claim", cueSurface: "cue_eval", claimsAuthorization: true}]])
}

negativeSemanticImpliesMutationReadiness: {
	semanticResolvedSurfaces: list.Concat([_baseLoadedContext.semanticResolvedSurfaces, [{id: "semantic.mutation.claim", cueSurface: "cue_eval", impliesMutationReadiness: true}]])
}

negativeAdapterPolicyOwnershipClaim: {
	adapterPolicyOwnershipClaims: ["adapter policy ownership"]
}

negativeAdapterOwnsPolicyTrue: {
	adapterOwnsPolicy: true
}

negativeCueOwnsPolicyFalse: {
	cueOwnsPolicy: false
}

negativeLegacyAuthorityTermActive: {
	legacyAuthorityTerms: ["legacy bootstrap authority"]
}

negativeUnboundedHomeSrcScanAdmitted: {
	unboundedRepoScansAdmitted: true
}

negativeDeniedSiblingRepoLoadable: {
	deniedSiblingLoadsLoadable: true
}

negativeUnvettedLeafAuthority: {
	vettedLeafSchemas: [{id: "leaf.unvetted", path: "/home/_404/src/dotfiles/cue/leaf.cue", loaded: true, vetted: false, authorityOwner: "cue"}]
}
