package git

#WorktreeRole:
	"primary" |
	"failure-repro" |
	"repair-proof" |
	"proof-stack" |
	"scratch"

#WorktreeAdmissionSource:
	"explicit-repo" |
	"contract-projected" |
	"sibling-worktree"

#Worktree: {
	id:         string
	path:       string
	role:       #WorktreeRole
	repoRoot:   string
	head:       #Ref
	objective?: string
	inputs?: [...string]

	admission: {
		allowed: bool
		source:  #WorktreeAdmissionSource
		proof:   string
	}

	state: {
		clean:       bool
		hasStaged:   bool
		hasUnstaged: bool
		conflicted:  bool
	}

	invariants: {
		pathBoundaryChecked: bool
		gitDirMayBeFile:     bool
		noSiblingScan:       bool
	}
}

#AdmittedWorktree: #Worktree & {
	admission: allowed: true
	invariants: {
		pathBoundaryChecked: true
		gitDirMayBeFile:     true
		noSiblingScan:       true
	}
}

#WorktreeTopology: {
	id:        string
	head:      #Ref
	objective: string
	inputs: [...string]
	worktrees: [...#AdmittedWorktree]

	invariants: {
		sameHEAD:        true
		sameObjective:   true
		sameInputs:      true
		isolatedPaths:   true
		noSiblingScan:   true
		gitDirMayBeFile: true
	}
}
