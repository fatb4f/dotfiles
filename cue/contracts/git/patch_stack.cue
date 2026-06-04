package git

#PatchRole:
	"reproduce-failure" |
	"classify-pressure" |
	"introduce-contract" |
	"repair-transition" |
	"prove-rebound" |
	"generalize-pattern" |
	"closeout"

#Patch: {
	id:     string
	commit: #Ref
	parent: #Ref

	role: #PatchRole

	scope: {
		files: [...string]
		domains: [...string]
	}

	evidence: {
		statusBefore: string
		diff:         string
		statusAfter:  string
		tests?: [...#CommandEvidence]
		cue?: [...#CommandEvidence]
	}

	admissible: bool
}

#AdmissiblePatch: #Patch & {
	admissible: true
}

#AdmissibleTransition: {
	from:   #Ref
	to:     #Ref
	patch:  #AdmissiblePatch
	result: "admitted"
}

#PatchStack: {
	id: string

	base: #Ref
	head: #Ref

	patches: [...#AdmissiblePatch]
	transitions?: [...#AdmissibleTransition]

	invariants: {
		ordered:             true
		parentChainValid:    true
		eachPatchAdmissible: true
		finalTreeValid:      true
		noScopeInversion:    true
	}
}
