package git

#HexSHA: =~"^[0-9a-f]{7,40}$"

#RepositoryState: "clean" | "dirty" | "staged" | "conflicted" | "detached"

#RefKind: "branch" | "tag" | "detached" | "commit"

#Ref: {
	name?: string
	sha:   #HexSHA
	kind:  #RefKind
}

#Repository: {
	root:        string
	gitDir:      string
	head:        #Ref
	defaultRef?: string

	state: #RepositoryState

	owns: [
		"repository state",
		"staging",
		"commit history",
		"refs",
		"worktrees",
	]

	forbidden: [
		"workflow execution",
		"eval generation",
		"dotfile materialization",
	]
}

#GitContract: {
	repo: #Repository
	worktrees: [...#Worktree]
	worktreeTopology?: #WorktreeTopology
	patchStack?:       #PatchStack
	evidence:          #GitEvidence
	gates:             #GitGates

	invariant: "Git is the temporal state and evidence rail, not workflow authority."
}

#RejectedGitContractCandidate: {
	candidate: _
	rejected:  true
	reasons: [...string]
}
