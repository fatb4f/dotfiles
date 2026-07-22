package contextmodel

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"list"
	"strings"
)

// Resolution normalizes every branch, tag, symbolic, or exact-hash selector to
// the exact commit hex. Raw selector spelling remains request transport only.
#GitCommittedSnapshotObservation: {
	ResolvedRevision=resolvedRevision: #GitObjectID
	requestedRevision:                 ResolvedRevision.hex

	Occurrences=occurrences: [...#GitCommittedOccurrence]

	// Symlinks and gitlinks are opaque structural occurrences. No emitted path
	// may claim to be a descendant of either entry.
	_opaqueDescendants: [
		for opaque in Occurrences if opaque.kind == "symlink" || opaque.kind == "submodule" {
			for candidate in Occurrences if strings.HasPrefix(candidate.path, opaque.path + "/") {
				_|_("opaque Git occurrence has descendant: " + candidate.path)
			}
		}
	]
}

#GitCommittedSnapshotFuzzPropertyID:
	"unknown-field-rejected" |
		"duplicate-path-rejected" |
		"unsorted-path-rejected" |
		"incompatible-mode-rejected" |
		"non-normalized-path-rejected" |
		"noncanonical-revision-rejected" |
		"malformed-object-id-rejected" |
		"malformed-digest-rejected" |
		"opaque-symlink-descendant-rejected" |
		"opaque-submodule-descendant-rejected" |
		"elevated-authority-rejected"

gitCommittedSnapshotFuzzProperties: close({
	"unknown-field-rejected":               true
	"duplicate-path-rejected":              true
	"unsorted-path-rejected":               true
	"incompatible-mode-rejected":           true
	"non-normalized-path-rejected":         true
	"noncanonical-revision-rejected":       true
	"malformed-object-id-rejected":         true
	"malformed-digest-rejected":            true
	"opaque-symlink-descendant-rejected":   true
	"opaque-submodule-descendant-rejected": true
	"elevated-authority-rejected":          true
})

#GitCommittedSnapshotAssertionCandidate: close({
	schema:         "kernel.git-committed-snapshot-assertion-candidate.v0"
	propertyID:     #GitCommittedSnapshotFuzzPropertyID
	mutationID:     #GraphID
	documentKind:   "observation" | "projection"
	expected:       "reject"
	observed:       "accept"
	documentJSON:   #NonEmptyString
	documentDigest: #Digest

	_digestMatch: documentDigest & ("sha256:" + hex.Encode(sha256.Sum256(documentJSON)))
})

#GitCommittedSnapshotQualificationReport: close({
	schema:           "kernel.git-committed-snapshot-qualification-report.v1"
	resolvedRevision: #NonEmptyString & =~"^[0-9a-f]+$"
	hydratorDigest:   #Digest
	fixtureCommits: close({
		A: #NonEmptyString & =~"^[0-9a-f]+$"
		B: #NonEmptyString & =~"^[0-9a-f]+$"
		C: #NonEmptyString & =~"^[0-9a-f]+$"
		D: #NonEmptyString & =~"^[0-9a-f]+$"
		E: #NonEmptyString & =~"^[0-9a-f]+$"
		F: #NonEmptyString & =~"^[0-9a-f]+$"
	})

	Declared=declaredPropertyIDs: [...#GitCommittedSnapshotPropertyID]
	generatedPropertyIDs:         Declared
	executedPropertyIDs:          Declared
	reportedPropertyIDs:          Declared

	propertyReport: close({
		schema: "kernel.git-committed-snapshot-property-report.v0"
		results: [...close({
			propertyID: #GitCommittedSnapshotPropertyID
			status:     "passed"
		})]
		_resultIDs: [for result in results {result.propertyID}]
		_unique:    list.UniqueItems(_resultIDs) & true
	})

	// The report itself remains canonical JSON-compatible and closed.
	_reportJSON: json.Marshal({
		schema:               schema
		resolvedRevision:     resolvedRevision
		hydratorDigest:       hydratorDigest
		fixtureCommits:       fixtureCommits
		declaredPropertyIDs:  declaredPropertyIDs
		generatedPropertyIDs: generatedPropertyIDs
		executedPropertyIDs:  executedPropertyIDs
		reportedPropertyIDs:  reportedPropertyIDs
		propertyReport:       propertyReport
	})
})
