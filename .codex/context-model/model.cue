package contextmodel

// Provisional root vocabulary for the dotfiles context-establishment workbook.
// This package is intentionally local and replaceable. It is not a generalized
// kernel and has no dependency on CUEstrap or kernel-spec runtime artifacts.

#NonEmptyString: string & !=""
#ID:             #NonEmptyString & =~"^[a-z0-9]+([._-][a-z0-9]+)*$"
#Path:           #NonEmptyString & !~"(^|/)\\.\\.(/|$)" & !~"^/"
#Digest:         #NonEmptyString & =~"^sha256:[0-9a-f]{64}$"
#Confidence:     number & >=0 & <=1
#NonEmptyIDs:    [...#ID] & [_, ...]

#ArtifactClass:  "source" | "generated_projection" | "runtime_observation"
#SemanticRole:   "authority" | "constraint" | "workflow" | "evidence"
#ClaimAuthority: "none" | "candidate" | "controller" | "root"

#SourceLocator: {
	path:      #Path
	revision?: #NonEmptyString
	digest?:   #Digest
}

#AuthorityBinding: {
	semanticRole:   #SemanticRole
	artifactClass:  #ArtifactClass
	claimAuthority: #ClaimAuthority
	sourceRef?:     #SourceLocator

	if artifactClass != "source" {
		claimAuthority: "none" | "candidate"
	}
	if semanticRole == "evidence" {
		claimAuthority: "none" | "candidate"
	}
}

#RepositoryCoordinate: {
	repository:  #NonEmptyString
	root:        #Path | "."
	revision:    #NonEmptyString
	moduleRoot?: #Path | "."
}

#ContextRequest: {
	schema:                 "dotfiles.context-request.v0"
	requestID:              #ID
	prompt:                 #NonEmptyString
	repository:             #RepositoryCoordinate
	allowedPaths:           [...#Path]
	requestedProjectionIDs: [...#ID]
}

#ObservationKind: "prompt" | "repository" | "git" | "file" | "provider" | "tool"

// Observations may carry backend-specific facts, but never claimant verdicts.
#ObservationFacts: {
	[string]:    _
	pass?:       _|_
	passed?:     _|_
	success?:    _|_
	valid?:      _|_
	complete?:   _|_
	admitted?:   _|_
	aligned?:    _|_
	sufficient?: _|_
}

#SourceObservation: {
	kind:    #ObservationKind
	subject: #NonEmptyString
	facts:   #ObservationFacts
	diagnostics: [...{
		code:    #NonEmptyString
		message: #NonEmptyString
	}]
	provenance: #AuthorityBinding & {
		artifactClass:  "runtime_observation" | "source"
		claimAuthority: "none" | "candidate"
	}
}

#Evidence: {
	summary:        #NonEmptyString
	observationIDs: #NonEmptyIDs
	provenance: #AuthorityBinding & {
		semanticRole:   "evidence"
		claimAuthority: "none" | "candidate"
	}
}

#HypothesisState: "candidate" | "accepted" | "rejected" | "superseded"

#ContextHypothesis: {
	kind:        #ID
	statement:   #NonEmptyString
	state:       #HypothesisState
	evidenceIDs: #NonEmptyIDs
	confidence:  #Confidence
	derivedBy:   #ID
}

#ContextFragment: {
	summary:       #NonEmptyString
	sourceRef:     #SourceLocator
	prerequisites: [...#ID]
	authority:     #AuthorityBinding
}

#ProviderKind: "lsp" | "mcp" | "types" | "tool" | "repository"

#Provider: {
	kind:         #ProviderKind
	languages:    [...#ID]
	pathGlobs:    [...#NonEmptyString]
	evidenceOnly: true
	authority: #AuthorityBinding & {
		semanticRole:   "evidence"
		claimAuthority: "none"
	}
}

#ProviderObservation: {
	providerID:    #ID
	observationID: #ID
	query:         #NonEmptyString
	bounded:       true
}

#Workflow: {
	summary: #NonEmptyString
	steps: [...{
		id:        #ID
		dependsOn: [...#ID]
	}]
	authority: #AuthorityBinding
}

#ContextInventory: {
	fragments: [#ID]: #ContextFragment
	providers: [#ID]: #Provider
	workflows: [#ID]: #Workflow
}

#SelectionReason: {
	...
	reason:      #NonEmptyString
	evidenceIDs: #NonEmptyIDs
}

#FragmentSelection: #SelectionReason & {
	fragmentID: #ID
}

#FileSelection: #SelectionReason & {
	path: #Path
}

#ProviderSelection: #SelectionReason & {
	providerID: #ID
}

#WorkflowSelection: #SelectionReason & {
	workflowID: #ID
}

#ContextGap: {
	kind:                #ID
	description:         #NonEmptyString
	blocksSufficiency:   bool
	requiredEvidenceIDs: [...#ID]
}

#ConflictResolution: "unresolved" | "prefer_left" | "prefer_right" | "superseded" | "merged"

#ContextConflict: {
	leftRef:     #ID
	rightRef:    #ID
	description: #NonEmptyString
	evidenceIDs: #NonEmptyIDs
	resolution:  #ConflictResolution
}

#SufficiencyState: "insufficient" | "provisional" | "sufficient"

#ContextSufficiency: {
	state:                 #SufficiencyState
	reasons:               [...#NonEmptyString] & [_, ...]
	blockingGapIDs:        [...#ID]
	unresolvedConflictIDs: [...#ID]

	if state == "sufficient" {
		blockingGapIDs:        []
		unresolvedConflictIDs: []
	}
}

#ContextPacket: {
	schema:        "dotfiles.context-packet.v0"
	requestID:     #ID
	contextDigest: #Digest
	selected: {
		fragmentIDs: [...#ID]
		files:       [...#Path]
		providerIDs: [...#ID]
		workflowIDs: [...#ID]
	}
	evidenceIDs:      [...#ID]
	unresolvedGapIDs: [...#ID]
	provenance: #AuthorityBinding & {
		artifactClass:  "generated_projection"
		claimAuthority: "none" | "candidate"
	}
}

#PluginProjectionKind: "agent_context_resolver" | "code_intel"

#PluginProjection: {
	kind:         #PluginProjectionKind
	packageRoot:  #Path
	inputSchema:  "dotfiles.context-state.v0"
	outputSchema: #NonEmptyString
	browserless:  bool
	authority: #AuthorityBinding & {
		artifactClass:  "generated_projection"
		claimAuthority: "none"
	}
}

#ContextState: {
	schema:    "dotfiles.context-state.v0"
	request:   #ContextRequest
	inventory: #ContextInventory
	observations: [#ID]: #SourceObservation
	providerObservations: [...#ProviderObservation]
	evidence: [#ID]:   #Evidence
	hypotheses: [#ID]: #ContextHypothesis
	selected: {
		fragments: [...#FragmentSelection]
		files:     [...#FileSelection]
		providers: [...#ProviderSelection]
		workflows: [...#WorkflowSelection]
	}
	gaps: [#ID]:      #ContextGap
	conflicts: [#ID]: #ContextConflict
	sufficiency: #ContextSufficiency
	projection?: #ContextPacket & {requestID: request.requestID}

	// Referential-integrity checks are derived values, not transport fields.
	_selectedFragments: [for selection in selected.fragments {
		inventory.fragments[selection.fragmentID]
	}]
	_selectedProviders: [for selection in selected.providers {
		inventory.providers[selection.providerID]
	}]
	_selectedWorkflows: [for selection in selected.workflows {
		inventory.workflows[selection.workflowID]
	}]
	_providerObservationRefs: [for item in providerObservations {
		provider:    inventory.providers[item.providerID]
		observation: observations[item.observationID]
	}]
	_evidenceObservationRefs: [for item in evidence {
		for observationID in item.observationIDs {
			observations[observationID]
		}
	}]
	_hypothesisEvidenceRefs: [for item in hypotheses {
		for evidenceID in item.evidenceIDs {
			evidence[evidenceID]
		}
	}]
	_blockingGapRefs: [for gapID in sufficiency.blockingGapIDs {
		gaps[gapID] & {blocksSufficiency: true}
	}]
	_unresolvedConflictRefs: [for conflictID in sufficiency.unresolvedConflictIDs {
		conflicts[conflictID] & {resolution: "unresolved"}
	}]
}

#MigrationBoundary: {
	status:                    "provisional"
	externalRuntimeDependency: false
	target:                    "unresolved"
	replacementRequires:       [...#ID] & [_, ...]
}

#ContextModel: {
	schema:    "dotfiles.context-model.v0"
	status:    "provisional"
	scope:     "dotfiles_codex_plugins"
	migration: #MigrationBoundary
	inventory: #ContextInventory
	projections: [#ID]: #PluginProjection
}
