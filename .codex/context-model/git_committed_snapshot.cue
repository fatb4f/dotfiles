package contextmodel

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"list"
	pathpkg "path"
)

#GitCommittedSnapshotRequest: close({
	schema:       "kernel.git-committed-snapshot-request.v0"
	repositoryID: #GraphID
	path:         #Path | "."
	revision:     #NonEmptyString
})

// Git object identity is transport-neutral. The object format is explicit so
// SHA-1 is not embedded in the repository ontology.
#GitObjectID: close({
	format: #GraphID
	hex:    #NonEmptyString & =~"^[0-9a-f]+$"
})

#GitCommittedKind: "blob" | "tree" | "symlink" | "submodule"

#GitCommittedModeKind: close({
	"040000": "tree"
	"100644": "blob"
	"100664": "blob"
	"100755": "blob"
	"120000": "symlink"
	"160000": "submodule"
})

#GitCommittedOccurrence: close({
	OccurrencePath=path: #Path & !="."
	mode:                #NonEmptyString
	kind:                #GitCommittedKind
	objectID:            #GitObjectID
	size?:               int & >=0

	_pathNormalized: pathpkg.Clean(OccurrencePath) & OccurrencePath
	_modeKnown:      #GitCommittedModeKind[mode]
	_kindCompatible: kind & _modeKnown

})

#GitCommittedSnapshotObservation: close({
	schema: "kernel.git-committed-snapshot-observation.v0"

	repositoryID:      #GraphID
	requestedRevision: #NonEmptyString
	resolvedRevision:  #GitObjectID
	rootTree:           #GitObjectID

	Occurrences=occurrences: [...#GitCommittedOccurrence]

	hydrator: close({
		identity: #GraphID
		digest:   #Digest
	})

	_occurrencePaths: [for occurrence in Occurrences {occurrence.path}]
	_pathsUnique:     list.UniqueItems(_occurrencePaths) & true
	_pathsSorted:     list.IsSortedStrings(_occurrencePaths) & true
})

#GitCommittedSnapshotProjection: close({
	schema: "kernel.git-committed-snapshot-projection.v0"

	Observation=observation: #GitCommittedSnapshotObservation
	SchemaDigest=schemaDigest: #Digest
	PolicyDigest=policyDigest: #Digest

	_observationJSON:   json.Marshal(Observation)
	observationDigest: "sha256:" + hex.Encode(sha256.Sum256(_observationJSON))

	_moduleID:        "sha256:" + hex.Encode(sha256.Sum256("git-module\u0000" + Observation.repositoryID))
	_rootNamespaceID: "sha256:" + hex.Encode(sha256.Sum256("git-root-namespace\u0000" + Observation.repositoryID))
	_evidenceID:      "sha256:" + hex.Encode(sha256.Sum256("git-observation-evidence\u0000" + observationDigest))
	_snapshotID: "sha256:" + hex.Encode(sha256.Sum256(
		observationDigest + "\u0000" + SchemaDigest + "\u0000" + PolicyDigest + "\u0000" + Observation.hydrator.digest,
	))

	Graph=graph: #ContextGraphSnapshot & {
		snapshotID: _snapshotID

		modules: {
			"\(_moduleID)": {
				kind:            "repository"
				name:            Observation.repositoryID
				rootNamespaceID: _rootNamespaceID
				source: {
					kind:       "git-repository"
					repository: Observation.repositoryID
					revision:   Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
					path:       "."
				}
				properties: {
					rootTree: Observation.rootTree.format + ":" + Observation.rootTree.hex
				}
			}
		}

		namespaces: {
			"\(_rootNamespaceID)": {
				moduleID:          _moduleID
				parentNamespaceID: null
				name:              Observation.repositoryID
				kind:              "repository-root"
				rootPath:          "."
				source: {
					kind:       "git-tree"
					repository: Observation.repositoryID
					revision:   Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
					path:       "."
					contentDigest: "git-" + Observation.rootTree.format + ":" + Observation.rootTree.hex
				}
			}
		}

		members: {
			for occurrence in Observation.occurrences {
				let occurrenceID = "sha256:" + hex.Encode(sha256.Sum256(
					Observation.repositoryID + "\u0000" + Observation.resolvedRevision.format + "\u0000" + Observation.resolvedRevision.hex + "\u0000" + occurrence.path,
				))
				"\(occurrenceID)": {
					moduleID:    _moduleID
					namespaceID: _rootNamespaceID
					name:        pathpkg.Base(occurrence.path)
					if occurrence.kind == "tree" {
						kind: "directory"
					}
					if occurrence.kind != "tree" {
						kind: "file"
					}
					path: occurrence.path
					source: {
						kind:          "git-" + occurrence.kind
						repository:    Observation.repositoryID
						revision:      Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
						path:          occurrence.path
						contentDigest: "git-" + occurrence.objectID.format + ":" + occurrence.objectID.hex
					}
					properties: {
						contentIdentity: "git-object:" + occurrence.objectID.format + ":" + occurrence.objectID.hex
						pathIdentity: "sha256:" + hex.Encode(sha256.Sum256(
							Observation.repositoryID + "\u0000" + occurrence.path,
						))
						occurrenceIdentity: occurrenceID
						gitMode:             occurrence.mode
						gitKind:             occurrence.kind
					}
				}
			}
		}

		relationships: {
			let rootRelationshipID = "sha256:" + hex.Encode(sha256.Sum256(
				"contains\u0000" + _moduleID + "\u0000" + _rootNamespaceID,
			))
			"\(rootRelationshipID)": {
				subject: {kind: "module", id: _moduleID}
				predicate: "contains"
				object: {kind: "namespace", id: _rootNamespaceID}
				evidenceIDs: [_evidenceID]
			}

			for occurrence in Observation.occurrences if pathpkg.Dir(occurrence.path) == "." {
				let occurrenceID = "sha256:" + hex.Encode(sha256.Sum256(
					Observation.repositoryID + "\u0000" + Observation.resolvedRevision.format + "\u0000" + Observation.resolvedRevision.hex + "\u0000" + occurrence.path,
				))
				let relationshipID = "sha256:" + hex.Encode(sha256.Sum256(
					"contains\u0000" + _rootNamespaceID + "\u0000" + occurrenceID,
				))
				"\(relationshipID)": {
					subject: {kind: "namespace", id: _rootNamespaceID}
					predicate: "contains"
					object: {kind: "member", id: occurrenceID}
					evidenceIDs: [_evidenceID]
				}
			}

			for occurrence in Observation.occurrences if pathpkg.Dir(occurrence.path) != "." {
				let parentPath = pathpkg.Dir(occurrence.path)
				let parentID = "sha256:" + hex.Encode(sha256.Sum256(
					Observation.repositoryID + "\u0000" + Observation.resolvedRevision.format + "\u0000" + Observation.resolvedRevision.hex + "\u0000" + parentPath,
				))
				let occurrenceID = "sha256:" + hex.Encode(sha256.Sum256(
					Observation.repositoryID + "\u0000" + Observation.resolvedRevision.format + "\u0000" + Observation.resolvedRevision.hex + "\u0000" + occurrence.path,
				))
				let relationshipID = "sha256:" + hex.Encode(sha256.Sum256(
					"contains\u0000" + parentID + "\u0000" + occurrenceID,
				))
				"\(relationshipID)": {
					subject: {kind: "member", id: parentID}
					predicate: "contains"
					object: {kind: "member", id: occurrenceID}
					evidenceIDs: [_evidenceID]
				}
			}
		}

		evidence: {
			"\(_evidenceID)": {
				kind: "observation"
				subject: {kind: "module", id: _moduleID}
				producer: null
				source: {
					kind:          "git-committed-snapshot"
					repository:    Observation.repositoryID
					revision:      Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
					path:          "."
					contentDigest: observationDigest
				}
				authority:      "candidate"
				payloadDigest: observationDigest
				diagnostics: []
				properties: {
					requestedRevision: Observation.requestedRevision
					resolvedRevision:  Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
					rootTree:          Observation.rootTree.format + ":" + Observation.rootTree.hex
					hydratorIdentity:  Observation.hydrator.identity
					hydratorDigest:    Observation.hydrator.digest
				}
			}
		}

		provenance: {
			authorityDigest: PolicyDigest
			schemaDigest:    SchemaDigest
			hydratorDigest:  Observation.hydrator.digest
			baseRevision:   Observation.resolvedRevision.format + ":" + Observation.resolvedRevision.hex
			baseTree:       Observation.rootTree.format + ":" + Observation.rootTree.hex
		}
	}

	collected: #ContextCollectedEvidenceEnvelope & {
		state: {
			evidenceID:         _evidenceID
			snapshotID:         Graph.snapshotID
			evidence:           Graph.evidence[_evidenceID]
			effectiveAuthority: "candidate"
		}
	}
})

#GitCommittedSnapshotPropertyID:
	"determinism" |
		"rename-content-preserved" |
		"content-edit-content-changed" |
		"unrelated-entry-preserved" |
		"mode-change-content-preserved" |
		"symlink-not-traversed" |
		"submodule-not-traversed" |
		"revision-bound"

// This manifest is consumed by the Go/CUE qualification runner. Its concrete
// key set is the declared side of the declared=generated=executed=reported gate.
gitCommittedSnapshotProperties: close({
	"determinism": true
	"rename-content-preserved": true
	"content-edit-content-changed": true
	"unrelated-entry-preserved": true
	"mode-change-content-preserved": true
	"symlink-not-traversed": true
	"submodule-not-traversed": true
	"revision-bound": true
})
