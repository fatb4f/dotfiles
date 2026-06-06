package l_legitimize

import "list"

#GateResult: {
	accepted: bool
	diagnostics: [...string]
}

#SurfaceBinding: {
	id:         string
	cueSurface: string
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

#LoadedContext: {
	id: string

	taskGraphContract:         _
	taskGraphContractAccepted: true

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

	_cueSurfaceIDs: [
		for surface in cueDeclaredSurfaces {
			surface.id
		},
	]

	_mcpCueSurfaceIDs: [
		for surface in mcpRegisteredSurfaces {
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

		for surface in semanticResolvedSurfaces {
			allSemanticSurfacesResolveToCue:  list.Contains(_cueSurfaceIDs, surface.cueSurface)
			noMutationFromSemanticResolution: surface.impliesMutationReadiness == false
		}

		for surface in mcpRegisteredSurfaces {
			allMCPToolsResolveToCue:       list.Contains(_cueSurfaceIDs, surface.cueSurface)
			noMutationFromMCPAvailability: true
		}

		for surface in setupAllowedSurfaces {
			allSetupToolsResolveToCue:  list.Contains(_cueSurfaceIDs, surface.cueSurface)
			noUndeclaredToolPermission: list.Contains(_cueSurfaceIDs, surface.cueSurface)
		}

		for surface in instructionReferencedSurfaces {
			allInstructionSurfacesResolveToCue: list.Contains(_cueSurfaceIDs, surface.cueSurface)
		}

		for surface in cueDeclaredSurfaces
		if surface.requiresMCPRegistration {
			allMCPToolsResolveToCue: list.Contains(_mcpCueSurfaceIDs, surface.id)
		}

		noLegacyAuthorityTerms:   len(legacyAuthorityTerms) == 0
		noAdapterPolicyOwnership: len(adapterPolicyOwnershipClaims) == 0 && adapterOwnsPolicy == false
		noPolicyOutsideCue:       cueOwnsPolicy == true && adapterOwnsPolicy == false && len(semanticPolicyOwnershipClaims) == 0
		noUnboundedRepoScan:      unboundedRepoScansAdmitted == false && deniedSiblingLoadsLoadable == false

		for load in loadedFiles {
			noUnboundedRepoScan: load.path != "/home/_404/src/*"
		}

		for leaf in vettedLeafSchemas {
			noUnvettedLeafAuthority: leaf.vetted == true && leaf.authorityOwner == "cue"
		}
	}

	result: {
		accepted: true
		rejectedReasons: []
		authorityOwner:   "cue"
		stageOwner:       "load"
		readyForValidate: true
		readyForMutation: false
	}
}

#LoadPhase: {
	"@context": "https://fatb4f.dev/ns/ralph/load/v0"
	"@id":      "ralph:L"
	"@type":    "ralph:PhaseNode"

	id:   "L"
	name: "load"

	input: {
		taskGraphContract:         _
		taskGraphContractAccepted: true
	}

	output: #LoadedContext

	accepted: output.result.accepted == true && output.result.readyForValidate == true && output.result.readyForMutation == false && output.checks.ambiguityCount == 0

	control: {
		invariants: [
			"L materializes bounded context from A.accepted",
			"loaded files are graph-declared or root-authorized",
			"L denies sibling loads",
			"L denies unbounded scans",
			"L does not authorize mutation",
		]
	}
}
