package git

#GitMutationTool:
	"git_add" |
	"git_reset" |
	"git_commit" |
	"git_commit_amend" |
	"git_cherry_pick" |
	"git_revert" |
	"git_worktree_mutation"

#GitMutationIntent: {
	tool:      #GitMutationTool
	objective: string
	targetPaths: [string, ...string]
}

#GitMutationAdmission: {
	accepted: true

	intent: #GitMutationIntent

	repo:             #Repository
	worktree:         #AdmittedWorktree
	worktreeTopology: #WorktreeTopology

	agentflowRun?: _
	agentflowNode: {
		mutationPolicy: "scoped"
		promoGate: {
			valid: true
		}
		projection: {
			exported:             true
			accepted:             true
			mutationScopeDerived: true
			mutationScope: [string, ...string]
		}
		firstMutation: {
			afterPromoGate:      true
			afterProjection:     true
			insideMutationScope: true
		}
	}
	agentflowManifest?: _
	agentflowManifestNode?: {
		mutationPolicy: "scoped"
		promoGate: {
			valid: true
		}
		projection: {
			exportedBeforeMutation:  true
			acceptedBeforeMutation:  true
			projectedBeforeMutation: true
			mutationScopeDerived:    true
			mutationScope: [string, ...string]
		}
		firstMutation: {
			afterPromoGate:                  true
			afterProjection:                 true
			insideMutationScope:             true
			mutationObservedAfterProjection: true
		}
	}

	evidence: #GitEvidence
	gates: {
		worktreeGate: {
			worktreeListObserved: true
			admissionChecked:     true
			noUnauthorizedPath:   true
		}
		preMutation: {
			statusObserved:                     true
			diffObserved:                       true
			stagedDiffReviewed:                 true
			toolAllowedByPromotionScope:        true
			targetPathsAllowedByPromotionScope: true
		}
	}

	invariant: "Git mutation is inadmissible unless backed by accepted agentflow pre-mutation gate evidence."
	...
}

#GitCommitAdmission: #GitMutationAdmission & {
	intent: tool: "git_commit"
	commit: {
		message: string
		sha?:    #HexSHA
	}
}

#GitCommitAmendAdmission: #GitMutationAdmission & {
	intent: tool: "git_commit_amend"
	commit: {
		message: string
		sha?:    #HexSHA
	}
	historyRewrite: {
		explicitHistoryRewriteAllowed: true
		currentHEADObserved:           true
		amendTargetMatchesHEAD:        true
	}
}

#GitRevisionMutationAdmission: #GitMutationAdmission & {
	intent: tool: "git_cherry_pick" | "git_revert"
	revision: {
		source:                  #Ref
		sourceRevisionObserved:  true
		preStatusCleanOrAllowed: true
		conflictPolicy:          string
	}
}

#RejectedGitMutationCandidate: {
	accepted:  false
	candidate: _
	violations: [string, ...string]
	rationale: string
}
