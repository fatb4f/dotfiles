package a_assemble

import "list"

#TaskState: "waiting" | "ready" | "running" | "terminated"

#TaskKind: "resolve_patterns" | "assemble_pattern_bundle" | "compose_task_graph_contract" | "vet_root_schema" | "vet_promo_gate" | "project_agent_context" | "init_agentflow_run" | "check_git_mutation" | "record_lifecycle"

#Runner: "pure-cue" | "cue-export" | "cue-vet" | "mcp-rag" | "mcp-composer" | "mcp-git" | "hookrail-evidence"

#ReferenceDependency: {
	from: string
	to:   string
	via:  "cue-reference" | "projection-evidence"
}

#TaskContract: {
	id:   string
	kind: #TaskKind
	dependsOn: [...string]
	input:             _
	output?:           _
	runner:            #Runner
	authority:         "cue"
	adapterOwnsPolicy: false
}

#TaskGraphContract: {
	id:                      string
	sourceRetrievalContract: string

	config: {
		root:       "cue/a_assemble"
		inferTasks: false
	}

	tasks: [string]: #TaskContract

	graph: {
		edgeAuthority: "cue-references"
		cyclic:        bool
		edges: [...#ReferenceDependency]
	}

	ambiguity: [...string]
}

#AssemblePhase: {
	"@context": "https://fatb4f.dev/ns/ralph/assemble/v0"
	"@id":      "ralph:A"
	"@type":    "ralph:PhaseNode"

	id:   "A"
	name: "assemble"

	input: {
		retrieval:         _
		retrievalAccepted: true
	}

	output: #TaskGraphContract

	accepted: output.graph.cyclic == false && len(output.ambiguity) == 0

	control: {
		invariants: [
			"A consumes only R-accepted facts",
			"A emits a candidate graph only",
			"A does not execute",
			"A does not legitimize",
		]
	}
}

#CueDeclaredSurface: {
	id:                      string
	kind:                    string
	authorityOwner:          "cue"
	requiresMCPRegistration: *false | bool
}

#CueResolvedSurface: {
	id:                       string
	cueSurface:               string
	claimsAuthorization:      *false | false
	impliesMutationReadiness: *false | false
	ownsPolicy:               *false | false
}

#SurfaceBinding: {
	id:         string
	cueSurface: string
}

#LoadedFile: {
	path:         string
	authorizedBy: "selected-node" | "selected-pattern" | "explicit-index" | "root-declared-fallback-surface" | "root-policy"
}

#DeniedLoad: {
	path:   string
	reason: string
}

#RootSchemaAuthority: {
	id:             string
	path:           string
	loaded:         true
	authorityOwner: "cue"
}

#LeafSchemaAuthority: {
	id:             string
	path:           string
	loaded:         true
	vetted:         true
	authorityOwner: "cue"
}

#AssembleLifecycleProjection: {
	assemble: {
		inputs: {
			cueDeclaredSurfaces: [...#CueDeclaredSurface]
			semanticResolvedSurfaces: [...#CueResolvedSurface]
			mcpRegisteredSurfaces: [...#SurfaceBinding]
			setupAllowedSurfaces: [...#SurfaceBinding]
			instructionReferencedSurfaces: [...#SurfaceBinding]
			loadedFiles: [...#LoadedFile]
			deniedLoads: [...#DeniedLoad]
			rootSchema: #RootSchemaAuthority
			vettedLeafSchemas: [...#LeafSchemaAuthority]

			adapterPolicyOwnershipClaims: [...string]
			semanticPolicyOwnershipClaims: [...string]
			legacyAuthorityTerms: [...string]
			unboundedRepoScansAdmitted: false
			deniedSiblingLoadsLoadable: false
			cueOwnsPolicy:              true
			adapterOwnsPolicy:          false
		}

		_cueSurfaceIDs: [
			for surface in inputs.cueDeclaredSurfaces {
				surface.id
			},
		]

		_mcpCueSurfaceIDs: [
			for surface in inputs.mcpRegisteredSurfaces {
				surface.cueSurface
			},
		]

		checks: {
			allSemanticSurfacesResolveToCue:    true
			allMCPToolsResolveToCue:            true
			allSetupToolsResolveToCue:          true
			allInstructionSurfacesResolveToCue: true
			noLegacyAuthorityTerms:             true
			noAdapterPolicyOwnership:           true
			noPolicyOutsideCue:                 true
			noMutationFromSemanticResolution:   true
			noMutationFromMCPAvailability:      true
			noUnboundedRepoScan:                true
			noUndeclaredToolPermission:         true
			noUnvettedLeafAuthority:            true
			ambiguityCount:                     0

			for surface in inputs.semanticResolvedSurfaces {
				allSemanticSurfacesResolveToCue:  list.Contains(_cueSurfaceIDs, surface.cueSurface)
				noMutationFromSemanticResolution: surface.impliesMutationReadiness == false
			}

			for surface in inputs.mcpRegisteredSurfaces {
				allMCPToolsResolveToCue:       list.Contains(_cueSurfaceIDs, surface.cueSurface)
				noMutationFromMCPAvailability: true
			}

			for surface in inputs.setupAllowedSurfaces {
				allSetupToolsResolveToCue:  list.Contains(_cueSurfaceIDs, surface.cueSurface)
				noUndeclaredToolPermission: list.Contains(_cueSurfaceIDs, surface.cueSurface)
			}

			for surface in inputs.instructionReferencedSurfaces {
				allInstructionSurfacesResolveToCue: list.Contains(_cueSurfaceIDs, surface.cueSurface)
			}

			for surface in inputs.cueDeclaredSurfaces
			if surface.requiresMCPRegistration {
				allMCPToolsResolveToCue: list.Contains(_mcpCueSurfaceIDs, surface.id)
			}

			noLegacyAuthorityTerms:   len(inputs.legacyAuthorityTerms) == 0
			noAdapterPolicyOwnership: len(inputs.adapterPolicyOwnershipClaims) == 0 && inputs.adapterOwnsPolicy == false
			noPolicyOutsideCue:       inputs.cueOwnsPolicy == true && inputs.adapterOwnsPolicy == false && len(inputs.semanticPolicyOwnershipClaims) == 0
			noUnboundedRepoScan:      inputs.unboundedRepoScansAdmitted == false && inputs.deniedSiblingLoadsLoadable == false

			for load in inputs.loadedFiles {
				noUnboundedRepoScan: load.path != "/home/_404/src/*"
			}

			for leaf in inputs.vettedLeafSchemas {
				noUnvettedLeafAuthority: leaf.vetted == true && leaf.authorityOwner == "cue"
			}
		}

		result: {
			accepted: true
			rejectedReasons: []
			authorityOwner:   "cue"
			stageOwner:       "assemble"
			readyForValidate: true
			readyForMutation: false
		}
	}
}
