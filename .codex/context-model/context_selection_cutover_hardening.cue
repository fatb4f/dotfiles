package contextmodel

import (
	"list"
	"strings"
)

// Canonicality is enforced at the complete application boundary rather than on
// the transport definitions themselves. This keeps malformed mutation fixtures
// representable until a property runner explicitly evaluates them.
#ContextSelectionCanonicalSurface: {
	Proposal=proposal:       #ContextRootProposal
	RootCatalog=rootCatalog: #ContextRootCatalog
	Proof=proof:             #ContextSelectionProof
	Aliases=aliases:         [...#ContextPacketEvidenceAlias]

	_proposalMemberIDsSorted:       list.IsSortedStrings(Proposal.memberIDs) & true
	_proposalMemberIDsUnique:       list.UniqueItems(Proposal.memberIDs) & true
	_proposalNamespaceIDsSorted:    list.IsSortedStrings(Proposal.namespaceIDs) & true
	_proposalNamespaceIDsUnique:    list.UniqueItems(Proposal.namespaceIDs) & true
	_proposalPathPrefixesSorted:    list.IsSortedStrings(Proposal.pathPrefixes) & true
	_proposalPathPrefixesUnique:    list.UniqueItems(Proposal.pathPrefixes) & true
	_catalogMemberIDsSorted:        list.IsSortedStrings(RootCatalog.memberIDs) & true
	_catalogMemberIDsUnique:        list.UniqueItems(RootCatalog.memberIDs) & true
	_catalogNamespaceIDsSorted:     list.IsSortedStrings(RootCatalog.namespaceIDs) & true
	_catalogNamespaceIDsUnique:     list.UniqueItems(RootCatalog.namespaceIDs) & true
	_catalogPathsSorted:            list.IsSortedStrings(RootCatalog.paths) & true
	_catalogPathsUnique:            list.UniqueItems(RootCatalog.paths) & true
	_relationshipsSorted:           list.IsSortedStrings(Proof.relationshipIDs) & true
	_relationshipsUnique:           list.UniqueItems(Proof.relationshipIDs) & true
	_evidenceSorted:                list.IsSortedStrings(Proof.evidenceIDs) & true
	_evidenceUnique:                list.UniqueItems(Proof.evidenceIDs) & true
	_effectiveFilesSorted:          list.IsSortedStrings(Proof.effectiveFiles) & true
	_effectiveFilesUnique:          list.UniqueItems(Proof.effectiveFiles) & true
	_selectedKeys:                  [for entity in Proof.selected {entity.kind + "\u0000" + entity.id}]
	_selectedUnique:                list.UniqueItems(_selectedKeys) & true
	_aliasGraphEvidenceIDs:         [for alias in Aliases {alias.graphEvidenceID}]
	_aliasPacketEvidenceIDs:        [for alias in Aliases {alias.packetEvidenceID}]
	_aliasGraphSorted:              list.IsSortedStrings(_aliasGraphEvidenceIDs) & true
	_aliasGraphUnique:              list.UniqueItems(_aliasGraphEvidenceIDs) & true
	_aliasPacketSorted:             list.IsSortedStrings(_aliasPacketEvidenceIDs) & true
	_aliasPacketUnique:             list.UniqueItems(_aliasPacketEvidenceIDs) & true
	_frontiers:                     [Proof.frontier0, Proof.frontier1, Proof.frontier2, Proof.frontier3, Proof.frontier4, Proof.frontier5, Proof.frontier6, Proof.frontier7, Proof.frontier8]
	_frontierCanonicality: [for frontier in _frontiers {
		let entityKeys = [for record in frontier.entities {
			record.entity.kind + "\u0000" + record.entity.id
		}]
		sorted: list.IsSortedStrings(entityKeys) & true
		unique: list.UniqueItems(entityKeys) & true
	}]
}

// Structural containment ancestry is permitted, but no path-bearing selected
// member or packet file may escape the request's allowed path boundary.
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
	CutoverRequest=request:         #ContextApplicationRequest
	CutoverSnapshot=snapshot:       #ContextGraphSnapshot
	CutoverProposal=proposal:       #ContextRootProposal
	CutoverRootCatalog=rootCatalog: #ContextRootCatalog
	CutoverProof=proof:             #ContextSelectionProof
	CutoverPacket=packet:           #ContextPacketV0Projection

	_cutoverCanonicalSurface: #ContextSelectionCanonicalSurface & {
		proposal:    CutoverProposal
		rootCatalog: CutoverRootCatalog
		proof:       CutoverProof
		aliases:     CutoverPacket.aliases
	}
	_cutoverRequestBoundary: #ContextSelectionRequestBoundary & {
		request:  CutoverRequest
		snapshot: CutoverSnapshot
		selected: CutoverProof.selected
		files:    CutoverProof.effectiveFiles
	}
}
