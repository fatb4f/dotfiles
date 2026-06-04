package git

#GitObservationTool:
	"git_status" |
	"git_diff_unstaged" |
	"git_diff_staged" |
	"git_log" |
	"git_show" |
	"git_worktree_list"

#GitObservationEvidence: #GitEvidence & {
	statusShort: #ObservedCommandEvidence
	diff:        #ObservedCommandEvidence
	diffStaged:  #ObservedCommandEvidence
}

#GitObservationContract: {
	repo: #Repository

	worktrees?: [...#Worktree]
	worktreeTopology?: #WorktreeTopology
	patchStack?:       #PatchStack

	evidence: #GitObservationEvidence
	gates: {
		preCloseout: #CloseoutGate.preCloseout
		worktreeGate?: {
			worktreeListObserved: true
			admissionChecked:     true
			noUnauthorizedPath:   true
		}
	}

	allowedTools: [...#GitObservationTool]
	invariant: "Git observation is read-only evidence collection and cannot authorize mutation."
}
