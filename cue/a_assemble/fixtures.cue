package a_assemble

import "list"

goodAssembly: #AssemblePhase & {
	input: {
		retrieval: {id: "retrieval.good"}
		retrievalAccepted: true
	}
	output: {
		id:                      "taskGraph.good"
		sourceRetrievalContract: "retrieval.good"
		tasks: {}
		graph: {cyclic: false, edges: []}
		ambiguity: []
	}
}

badCyclicGraph: #TaskGraphContract & {
	id:                      "taskGraph.bad.cyclic"
	sourceRetrievalContract: "retrieval.good"
	tasks: {}
	graph: {cyclic: true, edges: []}
	ambiguity: ["task_graph_cyclic"]
}

_baseAcceptedAssembleLifecycle: #AssembleLifecycleProjection & {
	assemble: {
		inputs: {
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
				{path: "/home/_404/src/dotfiles/cue/a_assemble/fixtures.cue", authorizedBy: "selected-pattern"},
			]
			deniedLoads: [
				{path: "/home/_404/src/frame/**", reason: "Sibling repo is not selected."},
				{path: "/home/_404/src/git-mcp-go/**", reason: "Sibling repo is not needed for this assemble contract change."},
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
	}
}

AcceptedAssembleLifecycleFixture: _baseAcceptedAssembleLifecycle

_rawAssembleInputs: {
	cueDeclaredSurfaces: *_baseAcceptedAssembleLifecycle.assemble.inputs.cueDeclaredSurfaces | [...{id: string, kind: string, authorityOwner: string, requiresMCPRegistration?: bool}]
	semanticResolvedSurfaces: *_baseAcceptedAssembleLifecycle.assemble.inputs.semanticResolvedSurfaces | [...{id: string, cueSurface: string, claimsAuthorization?: bool, impliesMutationReadiness?: bool, ownsPolicy?: bool}]
	mcpRegisteredSurfaces: *_baseAcceptedAssembleLifecycle.assemble.inputs.mcpRegisteredSurfaces | [...{id: string, cueSurface: string}]
	setupAllowedSurfaces: *_baseAcceptedAssembleLifecycle.assemble.inputs.setupAllowedSurfaces | [...{id: string, cueSurface: string}]
	instructionReferencedSurfaces: *_baseAcceptedAssembleLifecycle.assemble.inputs.instructionReferencedSurfaces | [...{id: string, cueSurface: string}]
	loadedFiles: *_baseAcceptedAssembleLifecycle.assemble.inputs.loadedFiles | [...{path: string, authorizedBy: string}]
	deniedLoads: *_baseAcceptedAssembleLifecycle.assemble.inputs.deniedLoads | [...{path: string, reason: string}]
	rootSchema: *_baseAcceptedAssembleLifecycle.assemble.inputs.rootSchema | {id: string, path: string, loaded: bool, authorityOwner: string}
	vettedLeafSchemas: *_baseAcceptedAssembleLifecycle.assemble.inputs.vettedLeafSchemas | [...{id: string, path: string, loaded: bool, vetted: bool, authorityOwner: string}]
	adapterPolicyOwnershipClaims: *_baseAcceptedAssembleLifecycle.assemble.inputs.adapterPolicyOwnershipClaims | [...string]
	semanticPolicyOwnershipClaims: *_baseAcceptedAssembleLifecycle.assemble.inputs.semanticPolicyOwnershipClaims | [...string]
	legacyAuthorityTerms: *_baseAcceptedAssembleLifecycle.assemble.inputs.legacyAuthorityTerms | [...string]
	unboundedRepoScansAdmitted: *_baseAcceptedAssembleLifecycle.assemble.inputs.unboundedRepoScansAdmitted | bool
	deniedSiblingLoadsLoadable: *_baseAcceptedAssembleLifecycle.assemble.inputs.deniedSiblingLoadsLoadable | bool
	cueOwnsPolicy:              *_baseAcceptedAssembleLifecycle.assemble.inputs.cueOwnsPolicy | bool
	adapterOwnsPolicy:          *_baseAcceptedAssembleLifecycle.assemble.inputs.adapterOwnsPolicy | bool
}

negativeMCPToolRegisteredNotDeclared: {
	assemble: inputs: _rawAssembleInputs & {
		mcpRegisteredSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.mcpRegisteredSurfaces, [{id: "mcp.undeclared", cueSurface: "undeclared_tool"}]])
	}
}

negativeCueSurfaceMissingRequiredMCP: {
	assemble: inputs: _rawAssembleInputs & {
		cueDeclaredSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.cueDeclaredSurfaces, [{id: "required_missing_mcp", kind: "mcp-tool", authorityOwner: "cue", requiresMCPRegistration: true}]])
	}
}

negativeSetupToolNotDeclared: {
	assemble: inputs: _rawAssembleInputs & {
		setupAllowedSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.setupAllowedSurfaces, [{id: "setup.undeclared", cueSurface: "undeclared_tool"}]])
	}
}

negativeInstructionSurfaceNotDeclared: {
	assemble: inputs: _rawAssembleInputs & {
		instructionReferencedSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.instructionReferencedSurfaces, [{id: "instruction.undeclared", cueSurface: "undeclared_surface"}]])
	}
}

negativeSemanticClaimsAuthorization: {
	assemble: inputs: _rawAssembleInputs & {
		semanticResolvedSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.semanticResolvedSurfaces, [{id: "semantic.auth.claim", cueSurface: "cue_eval", claimsAuthorization: true}]])
	}
}

negativeSemanticImpliesMutationReadiness: {
	assemble: inputs: _rawAssembleInputs & {
		semanticResolvedSurfaces: list.Concat([_baseAcceptedAssembleLifecycle.assemble.inputs.semanticResolvedSurfaces, [{id: "semantic.mutation.claim", cueSurface: "cue_eval", impliesMutationReadiness: true}]])
	}
}

negativeAdapterPolicyOwnershipClaim: {
	assemble: inputs: _rawAssembleInputs & {
		adapterPolicyOwnershipClaims: ["adapter policy ownership"]
	}
}

negativeAdapterOwnsPolicyTrue: {
	assemble: inputs: _rawAssembleInputs & {
		adapterOwnsPolicy: true
	}
}

negativeCueOwnsPolicyFalse: {
	assemble: inputs: _rawAssembleInputs & {
		cueOwnsPolicy: false
	}
}

negativeLegacyAuthorityTermActive: {
	assemble: inputs: _rawAssembleInputs & {
		legacyAuthorityTerms: ["legacy bootstrap authority"]
	}
}

negativeUnboundedHomeSrcScanAdmitted: {
	assemble: inputs: _rawAssembleInputs & {
		unboundedRepoScansAdmitted: true
	}
}

negativeDeniedSiblingRepoLoadable: {
	assemble: inputs: _rawAssembleInputs & {
		deniedSiblingLoadsLoadable: true
	}
}

negativeUnvettedLeafAuthority: {
	assemble: inputs: _rawAssembleInputs & {
		vettedLeafSchemas: [{id: "leaf.unvetted", path: "/home/_404/src/dotfiles/cue/leaf.cue", loaded: true, vetted: false, authorityOwner: "cue"}]
	}
}

negativeAmbiguityCountNonZero: {
	assemble: {
		inputs: _rawAssembleInputs
		checks: ambiguityCount: 1
	}
}

negativeReadyForMutationTrue: {
	assemble: {
		inputs: _rawAssembleInputs
		result: readyForMutation: true
	}
}
