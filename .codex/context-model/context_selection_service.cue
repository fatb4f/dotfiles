package contextmodel

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"list"
)

// The application boundary is deliberately smaller than the workbook request.
// A caller may propose roots, but may not submit selected graph state.
#ContextApplicationRequest: close({
	schema:     "dotfiles.context-application-request.v0"
	requestID:  #ID
	repository: #NonEmptyString
	revision:   #NonEmptyString

	allowedPaths: [#Path | ".", ...#Path | "."]
	overlayMode:  "disabled" | "required" | "auto"
	roots: close({
		memberIDs:    [...#GraphID]
		namespaceIDs: [...#GraphID]
		pathPrefixes: [...#Path | "."]
	})
})

#ContextRootProposal: close({
	schema:     "dotfiles.context-root-proposal.v0"
	requestID:  #ID
	snapshotID: #Digest

	memberIDs:    [...#GraphID]
	namespaceIDs: [...#GraphID]
	pathPrefixes: [...#Path | "."]
})

#ContextRootCatalog: close({
	schema:     "dotfiles.context-root-catalog.v0"
	requestID:  #ID
	snapshotID: #Digest

	memberIDs:    [...#GraphID]
	namespaceIDs: [...#GraphID]
	paths:        [...#Path]

	_membersBounded:    len(memberIDs) <= 2048
	_namespacesBounded: len(namespaceIDs) <= 256
	_pathsBounded:      len(paths) <= 2048
	_canonicalBytes: json.Marshal({
		schema:       schema
		requestID:    requestID
		snapshotID:   snapshotID
		memberIDs:    memberIDs
		namespaceIDs: namespaceIDs
		paths:        paths
	})
	_bytesBounded: len(_canonicalBytes) <= 262144
})

#ContextSelectionLimits: close({
	maxDepth:             int & >=0 & <=8 | *8
	maxRoots:             int & >=1 | *64
	maxModules:           int & >=1 | *8
	maxNamespaces:        int & >=1 | *64
	maxMembers:           int & >=1 | *256
	maxEntities:          int & >=1 | *320
	maxFiles:             int & >=1 | *32
	maxSelectedFileBytes: int & >=1 | *1048576
	maxRelationships:     int & >=1 | *512
	maxEvidence:          int & >=1 | *128
	maxPredicates:        int & >=1 | *8
	maxPacketBytes:       int & >=1 | *65536
})

#ContextSelectionPolicy: close({
	schema:     "dotfiles.context-selection-policy.v0"
	predicates: [...#ContextPredicate]
	limits:     #ContextSelectionLimits

	// v0 traversal is intentionally a one-element allowlist. Enriched
	// relationships remain graph facts but cannot widen this selection.
	_predicateLimit: len(predicates) <= limits.maxPredicates
	_predicatesKnown: [for predicate in predicates {
		predicate & "contains"
	}]
})

#GitEffectiveOccurrence: close({
	path:   #Path
	layer:  "committed" | "index" | "worktree"
	status: "present" | "deleted"
	kind:   "blob" | "symlink" | "tree" | "submodule" | "tombstone"

	memberID:      #GraphID
	evidenceID:    #GraphID
	gitSizeBytes?: int & >=0

	if status == "present" && (kind == "blob" || kind == "symlink") {
		gitSizeBytes: int & >=0
	}
})

#GitEffectivePathView: close({
	schema:     "dotfiles.git-effective-path-view.v0"
	snapshotID: #Digest
	paths:      [...#GitEffectiveOccurrence]
})

#GitPathLayerOccurrence: close({
	path:          #Path
	status:        "present" | "deleted"
	kind:          "blob" | "symlink" | "tree" | "submodule" | "tombstone"
	memberID:      #GraphID
	evidenceID:    #GraphID
	gitSizeBytes?: int & >=0
})

// The orchestrator calculates the candidate path union. CUE proves that it is
// sorted, unique, complete, and that every projected winner follows Git layer
// precedence. A deletion is a winner, not absence.
#GitEffectivePathEvaluation: close({
	snapshotID: #Digest
	allPaths:   [...#Path]
	committed:  [...#GitPathLayerOccurrence]
	index:      [...#GitPathLayerOccurrence]
	worktree:   [...#GitPathLayerOccurrence]

	_committedPaths:  [for occurrence in committed {occurrence.path}]
	_indexPaths:      [for occurrence in index {occurrence.path}]
	_worktreePaths:   [for occurrence in worktree {occurrence.path}]
	_committedSorted: list.IsSortedStrings(_committedPaths) & true
	_indexSorted:     list.IsSortedStrings(_indexPaths) & true
	_worktreeSorted:  list.IsSortedStrings(_worktreePaths) & true
	_committedUnique: list.UniqueItems(_committedPaths) & true
	_indexUnique:     list.UniqueItems(_indexPaths) & true
	_worktreeUnique:  list.UniqueItems(_worktreePaths) & true

	_allObservedPaths: [
		for occurrence in committed {occurrence.path},
		for occurrence in index {occurrence.path},
		for occurrence in worktree {occurrence.path},
	]
	_pathsSorted: list.IsSortedStrings(allPaths) & true
	_pathsUnique: list.UniqueItems(allPaths) & true
	_pathCoverage: [for path in allPaths {
		[for observed in _allObservedPaths if observed == path {observed}] & [_, ...]
	}]
	_observationCoverage: [for observed in _allObservedPaths {
		[for path in allPaths if path == observed {path}] & [_, ...]
	}]

	view: #GitEffectivePathView & {
		snapshotID: snapshotID
		paths: [for path in allPaths {
			let committedMatches = [for occurrence in committed if occurrence.path == path {occurrence}]
			let indexMatches = [for occurrence in index if occurrence.path == path {occurrence}]
			let worktreeMatches = [for occurrence in worktree if occurrence.path == path {occurrence}]
			if len(worktreeMatches) > 0 {
				worktreeMatches[0] & {layer: "worktree"}
			}
			if len(worktreeMatches) == 0 && len(indexMatches) > 0 {
				indexMatches[0] & {layer: "index"}
			}
			if len(worktreeMatches) == 0 && len(indexMatches) == 0 {
				committedMatches[0] & {layer: "committed"}
			}
		}]
	}
})

#ContextTraversalRecord: close({
	entity:      #ContextEntityRef
	distance:    int & >=0 & <=8
	direction:   "root" | "outgoing"
	predecessor: #GraphID | null
})

#ContextSelectionFrontier: close({
	distance: int & >=0 & <=8
	entities: [...#ContextTraversalRecord]
})

#ContextSelectionProof: close({
	schema:     "dotfiles.context-selection-proof.v0"
	snapshotID: #Digest

	frontier0: #ContextSelectionFrontier & {distance: 0}
	frontier1: #ContextSelectionFrontier & {distance: 1}
	frontier2: #ContextSelectionFrontier & {distance: 2}
	frontier3: #ContextSelectionFrontier & {distance: 3}
	frontier4: #ContextSelectionFrontier & {distance: 4}
	frontier5: #ContextSelectionFrontier & {distance: 5}
	frontier6: #ContextSelectionFrontier & {distance: 6}
	frontier7: #ContextSelectionFrontier & {distance: 7}
	frontier8: #ContextSelectionFrontier & {distance: 8}

	selected:        [...#ContextEntityRef]
	relationshipIDs: [...#GraphID]
	evidenceIDs:     [...#GraphID]
	effectiveFiles:  [...#Path]

	counters: close({
		modules:       int & >=0
		namespaces:    int & >=0
		members:       int & >=0
		entities:      int & >=0
		files:         int & >=0
		fileBytes:     int & >=0
		relationships: int & >=0
		evidence:      int & >=0
	})
	contextDigest: #Digest
	packetDigest:  #Digest
})

#ContextPacketEvidenceAlias: close({
	graphEvidenceID:  #GraphID
	packetEvidenceID: "evidence." + #NonEmptyString
})

#ContextPacketV0Projection: close({
	adapterVersion: "context-packet-v0-adapter.v1"
	aliases:        [...#ContextPacketEvidenceAlias]
	packet:         #ContextPacket

	_aliasDerivations: [for alias in aliases {
		let digest = hex.Encode(sha256.Sum256(alias.graphEvidenceID))
		alias.packetEvidenceID & "evidence.\(digest)"
	}]
})

#ContextSelectionEvaluation: close({
	request:       #ContextApplicationRequest
	proposal:      #ContextRootProposal
	policy:        #ContextSelectionPolicy
	snapshot:      #ContextGraphSnapshot
	effectiveView: #GitEffectivePathView
	proof:         #ContextSelectionProof
	resolution:    #ContextGraphResolution
	packet:        #ContextPacketV0Projection

	_requestProposal:         request.requestID & proposal.requestID
	_proposalSnapshot:        proposal.snapshotID & snapshot.snapshotID
	_viewSnapshot:            effectiveView.snapshotID & snapshot.snapshotID
	_proofSnapshot:           proof.snapshotID & snapshot.snapshotID
	_resolutionSnapshot:      resolution.snapshot.snapshotID & snapshot.snapshotID
	_resolutionRequest:       resolution.selection.requestID & request.requestID
	_resolutionSelected:      resolution.selection.selected & proof.selected
	_resolutionRelationships: resolution.selection.relationshipIDs & proof.relationshipIDs
	_resolutionEvidence:      resolution.selection.evidenceIDs & proof.evidenceIDs
	_packetRequest:           packet.packet.requestID & request.requestID
	_packetDigest:            packet.packet.contextDigest & proof.contextDigest
	_packetFiles:             packet.packet.selected.files & proof.effectiveFiles

	_rootCount:            len(proposal.memberIDs) + len(proposal.namespaceIDs) + len(proposal.pathPrefixes)
	_rootsBounded:         _rootCount <= policy.limits.maxRoots
	_modulesBounded:       proof.counters.modules <= policy.limits.maxModules
	_namespacesBounded:    proof.counters.namespaces <= policy.limits.maxNamespaces
	_membersBounded:       proof.counters.members <= policy.limits.maxMembers
	_entitiesBounded:      proof.counters.entities <= policy.limits.maxEntities
	_filesBounded:         proof.counters.files <= policy.limits.maxFiles
	_fileBytesBounded:     proof.counters.fileBytes <= policy.limits.maxSelectedFileBytes
	_relationshipsBounded: proof.counters.relationships <= policy.limits.maxRelationships
	_evidenceBounded:      proof.counters.evidence <= policy.limits.maxEvidence
	_packetCanonical:      json.Marshal(packet.packet)
	_packetBytesBounded:   len(_packetCanonical) <= policy.limits.maxPacketBytes
	_packetDigestDerived:  proof.packetDigest & ("sha256:" + hex.Encode(sha256.Sum256(_packetCanonical)))

	_counterEntities:      proof.counters.entities & len(proof.selected)
	_counterFiles:         proof.counters.files & len(proof.effectiveFiles)
	_counterRelationships: proof.counters.relationships & len(proof.relationshipIDs)
	_counterEvidence:      proof.counters.evidence & len(proof.evidenceIDs)
})

#ContextGraphFailure: close({
	schema:    "dotfiles.context-graph-failure.v0"
	requestID: #ID
	stage:     "revision" | "manifest" | "hydration" | "snapshot" | "proposal" | "selection" | "packet"
	code:      #GraphID
	message:   #NonEmptyString
	details: [string]: _
})

#ContextGraphServiceSuccess: close({
	schema:     "dotfiles.context-graph-service-result.v0"
	status:     "success"
	evaluation: #ContextSelectionEvaluation
})

#ContextGraphServiceFailure: close({
	schema:  "dotfiles.context-graph-service-result.v0"
	status:  "failure"
	failure: #ContextGraphFailure
})

#ContextGraphServiceResult: #ContextGraphServiceSuccess | #ContextGraphServiceFailure
