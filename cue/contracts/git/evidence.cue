package git

#CommandEvidence: {
	command:  string
	exitCode: int
	stdout:   string
	stderr?:  string
	observed: bool
}

#ObservedCommandEvidence: #CommandEvidence & {
	observed: true
}

#EvidenceArtifactKind:
	"status-short" |
	"diff" |
	"diff-staged" |
	"log" |
	"worktree-list" |
	"commit-sha"

#EvidenceArtifact: {
	kind:     #EvidenceArtifactKind
	source:   string
	observed: true
}

#GitEvidence: {
	statusShort: #ObservedCommandEvidence
	diff:        #ObservedCommandEvidence
	diffStaged:  #ObservedCommandEvidence
	log?:        #ObservedCommandEvidence
	worktrees?:  #ObservedCommandEvidence
	commit?: {
		sha:     #HexSHA
		message: string
	}
	artifacts?: [...#EvidenceArtifact]
}

#CloseoutGate: {
	preCloseout: {
		statusObserved: true
		diffObserved:   true
	}
}

#GitGates: {
	preCloseout: #CloseoutGate.preCloseout

	commitGate?: {
		stagedDiffReviewed: true
		commitCreated:      true
		commitSHA:          #HexSHA
	}

	worktreeGate?: {
		worktreeListObserved: true
		admissionChecked:     true
		noUnauthorizedPath:   true
	}
}
