package contextmodel

import (
	"list"
	"strings"
)

// Proposal and catalog lists are transport boundaries. They must be canonical
// before they can participate in digests or root resolution.
#ContextRootProposal: {
	MemberIDs=memberIDs:       [...#GraphID]
	NamespaceIDs=namespaceIDs: [...#GraphID]
	PathPrefixes=pathPrefixes: [...#Path | "."]

	_memberIDsSorted:    list.IsSortedStrings(MemberIDs) & true
	_memberIDsUnique:    list.UniqueItems(MemberIDs) & true
	_namespaceIDsSorted: list.IsSortedStrings(NamespaceIDs) & true
	_namespaceIDsUnique: list.UniqueItems(NamespaceIDs) & true
	_pathPrefixesSorted: list.IsSortedStrings(PathPrefixes) & true
	_pathPrefixesUnique: list.UniqueItems(PathPrefixes) & true
}

#ContextRootCatalog: {
	MemberIDs=memberIDs:       [...#GraphID]
	NamespaceIDs=namespaceIDs: [...#GraphID]
	Paths=paths:               [...#Path]

	_memberIDsSorted:    list.IsSortedStrings(MemberIDs) & true
	_memberIDsUnique:    list.UniqueItems(MemberIDs) & true
	_namespaceIDsSorted: list.IsSortedStrings(NamespaceIDs) & true
	_namespaceIDsUnique: list.UniqueItems(NamespaceIDs) & true
	_pathsSorted:        list.IsSortedStrings(Paths) & true
	_pathsUnique:        list.UniqueItems(Paths) & true
}

// Traversal remains ordered by shortest distance. Within each distance, entity
// records are canonical by kind and ID and may not repeat an entity.
#ContextSelectionFrontier: {
	Entities=entities: [...#ContextTraversalRecord]
	_entityKeys: [for record in Entities {
		record.entity.kind + "\u0000" + record.entity.id
	}]
	_entitiesSorted: list.IsSortedStrings(_entityKeys) & true
	_entitiesUnique: list.UniqueItems(_entityKeys) & true
}

#ContextSelectionProof: {
	Selected=selected:               [...#ContextEntityRef]
	RelationshipIDs=relationshipIDs: [...#GraphID]
	EvidenceIDs=evidenceIDs:         [...#GraphID]
	EffectiveFiles=effectiveFiles:   [...#Path]

	_selectedKeys: [for entity in Selected {
		entity.kind + "\u0000" + entity.id
	}]
	_selectedUnique:       list.UniqueItems(_selectedKeys) & true
	_relationshipsSorted:  list.IsSortedStrings(RelationshipIDs) & true
	_relationshipsUnique:  list.UniqueItems(RelationshipIDs) & true
	_evidenceSorted:       list.IsSortedStrings(EvidenceIDs) & true
	_evidenceUnique:       list.UniqueItems(EvidenceIDs) & true
	_effectiveFilesSorted: list.IsSortedStrings(EffectiveFiles) & true
	_effectiveFilesUnique: list.UniqueItems(EffectiveFiles) & true
}

#ContextPacketV0Projection: {
	Aliases=aliases: [...#ContextPacketEvidenceAlias]
	_aliasGraphEvidenceIDs:  [for alias in Aliases {alias.graphEvidenceID}]
	_aliasPacketEvidenceIDs: [for alias in Aliases {alias.packetEvidenceID}]
	_aliasGraphSorted:       list.IsSortedStrings(_aliasGraphEvidenceIDs) & true
	_aliasGraphUnique:       list.UniqueItems(_aliasGraphEvidenceIDs) & true
	_aliasPacketSorted:      list.IsSortedStrings(_aliasPacketEvidenceIDs) & true
	_aliasPacketUnique:      list.UniqueItems(_aliasPacketEvidenceIDs) & true
}

// This helper is reusable by property fixtures and by the complete evaluation.
// It permits structural containment ancestry, but no path-bearing member or
// packet file may escape the request's allowed path boundary.
#ContextSelectionRequestBoundary: {
	Request=request:      #ContextApplicationRequest
	Snapshot=snapshot:    #ContextGraphSnapshot
	Selected=selected:    [...#ContextEntityRef]
	EffectiveFiles=files: [...#Path]

	_selectedMembersBounded: [for selectedEntity in Selected
	if selectedEntity.kind == "member" {
		let selectedMember = Snapshot.members[selectedEntity.id]
		if selectedMember.path != _|_ {
			[for allowed in Request.allowedPaths
			if allowed == "." || selectedMember.path == allowed ||
				strings.HasPrefix(selectedMember.path, allowed + "/") {
				allowed
			}] & [_, ...]
		}
	}]
	_effectiveFilesBounded: [for selectedPath in EffectiveFiles {
		[for allowed in Request.allowedPaths
		if allowed == "." || selectedPath == allowed ||
			strings.HasPrefix(selectedPath, allowed + "/") {
			allowed
		}] & [_, ...]
	}]
}

#ContextSelectionEvaluation: {
	Request=request:   #ContextApplicationRequest
	Snapshot=snapshot: #ContextGraphSnapshot
	Proof=proof:       #ContextSelectionProof

	_requestBoundary: #ContextSelectionRequestBoundary & {
		request:  Request
		snapshot: Snapshot
		selected: Proof.selected
		files:    Proof.effectiveFiles
	}
}
