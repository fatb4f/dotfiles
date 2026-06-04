package fixtures

import (
	agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"
	git "github.com/fatb4f/dotfiles/cue/contracts/git"
)

_repo: git.#Repository & {
	root:   "/home/_404/src/dotfiles"
	gitDir: "/home/_404/src/dotfiles/.git"
	head: {
		name: "main"
		sha:  "abc1234"
		kind: "branch"
	}
	defaultRef: "main"
	state:      "staged"
}

_worktree: git.#AdmittedWorktree & {
	id:        "primary-dotfiles"
	path:      "/home/_404/src/dotfiles"
	role:      "primary"
	repoRoot:  "/home/_404/src/dotfiles"
	head:      _repo.head
	objective: "Admit Git commit mutation from accepted agentflow pre-mutation evidence."
	inputs: [
		"cue/contracts/git/mutation.cue",
		"cue/contracts/git/fixtures/mutation.cue",
	]
	admission: {
		allowed: true
		source:  "explicit-repo"
		proof:   "git_worktree_list observed the selected repository path and path boundary"
	}
	state: {
		clean:       false
		hasStaged:   true
		hasUnstaged: false
		conflicted:  false
	}
	invariants: {
		pathBoundaryChecked: true
		gitDirMayBeFile:     true
		noSiblingScan:       true
	}
}

_topology: git.#WorktreeTopology & {
	id:        "git-mutation-admitted-topology"
	head:      _repo.head
	objective: _worktree.objective
	inputs:    _worktree.inputs
	worktrees: [_worktree]
	invariants: {
		sameHEAD:        true
		sameObjective:   true
		sameInputs:      true
		isolatedPaths:   true
		noSiblingScan:   true
		gitDirMayBeFile: true
	}
}

_evidence: git.#GitEvidence & {
	statusShort: {
		command:  "git status --short"
		exitCode: 0
		stdout:   "M  cue/contracts/git/mutation.cue\n"
		observed: true
	}
	diff: {
		command:  "git diff"
		exitCode: 0
		stdout:   ""
		observed: true
	}
	diffStaged: {
		command:  "git diff --staged"
		exitCode: 0
		stdout:   "diff --git a/cue/contracts/git/mutation.cue b/cue/contracts/git/mutation.cue\n"
		observed: true
	}
	worktrees: {
		command:  "git worktree list"
		exitCode: 0
		stdout:   "/home/_404/src/dotfiles  abc1234 [main]\n"
		observed: true
	}
	artifacts: [
		{kind: "status-short", source: "git status --short", observed: true},
		{kind: "diff", source: "git diff", observed: true},
		{kind: "diff-staged", source: "git diff --staged", observed: true},
		{kind: "worktree-list", source: "git worktree list", observed: true},
	]
}

_agentflowRun: agentflow.#AcceptedAgentFlowRun & {
	objective: _worktree.objective
	rootResponse: {
		objective: _worktree.objective
		rootConsultation: {
			viaTransport:       true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   true
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     true
			promoGateRequirementsImported: true
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			selectedWorkflow:          "agentflow.premutation.git-mutation"
			executionEnvelope: {
				planID: "plan.git-mutation-admission"
				scope: [
					"cue/contracts/git/mutation.cue",
					"cue/contracts/git/fixtures/mutation.cue",
				]
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	plan: {
		id:               "plan.git-mutation-admission"
		objective:        _worktree.objective
		selectedWorkflow: "agentflow.premutation.git-mutation"
		nodes: [
			{
				id:             "git-commit"
				domain:         "git"
				objectiveSlice: "Commit only the accepted projection scope."
				predecessors: ["git-observation"]
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					source:               "agentflow.premutation.git-mutation"
					evidencePath:         "cue/contracts/git/fixtures/mutation.cue#git-commit"
					evidenceGenerated:    true
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                 "git.mutation.admission-scope"
					exported:             true
					accepted:             true
					mutationScopeDerived: true
					mutationScope: [
						"cue/contracts/git/mutation.cue",
						"cue/contracts/git/fixtures/mutation.cue",
					]
				}
				firstMutation: {
					path:                "cue/contracts/git/mutation.cue"
					line:                1
					timestamp:           "2026-06-03T00:00:00Z"
					afterPromoGate:      true
					afterProjection:     true
					insideMutationScope: true
				}
				validationEvidence: [
					"cue vet ./cue/contracts/git/...",
				]
			},
		]
		edges: []
		derived: {
			nodeOrder: ["git-commit"]
			allNodesHavePromoGates:   true
			allExecutedNodesAccepted: true
			noMutatingNodeBeforeGate: true
		}
	}
	manifest: {
		runID:     "git-mutation-admission.good"
		objective: _worktree.objective
		root: {
			consultedViaTransport: true
			responseAccepted:      true
		}
		plan: {
			id:               "plan.git-mutation-admission"
			selectedWorkflow: "agentflow.premutation.git-mutation"
			nodeOrder: ["git-commit"]
			edges: []
		}
		domainNodes: [
			{
				id:             "git-commit"
				domain:         "git"
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/git/fixtures/mutation.cue#git-commit"
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                    "git.mutation.admission-scope"
					exportedBeforeMutation:  true
					acceptedBeforeMutation:  true
					projectedBeforeMutation: true
					mutationScopeDerived:    true
					mutationScope: [
						"cue/contracts/git/mutation.cue",
						"cue/contracts/git/fixtures/mutation.cue",
					]
				}
				firstMutation: {
					path:                            "cue/contracts/git/mutation.cue"
					afterPromoGate:                  true
					afterProjection:                 true
					insideMutationScope:             true
					mutationObservedAfterProjection: true
				}
			},
		]
		derived: {
			allPromoEvidenceCueVetted: true
			allDomainNodesAccepted:    true
			noMutatingNodeBeforeGate:  true
		}
		closeout: {
			runManifestWritten:   true
			runManifestCueVetted: true
		}
	}
}

_agentflowNode: {
	mutationPolicy: _agentflowRun.plan.nodes[0].mutationPolicy
	promoGate: {
		valid: _agentflowRun.plan.nodes[0].promoGate.valid
	}
	projection: {
		exported:             _agentflowRun.plan.nodes[0].projection.exported
		accepted:             _agentflowRun.plan.nodes[0].projection.accepted
		mutationScopeDerived: _agentflowRun.plan.nodes[0].projection.mutationScopeDerived
		mutationScope:        _agentflowRun.plan.nodes[0].projection.mutationScope
	}
	firstMutation: {
		afterPromoGate:      _agentflowRun.plan.nodes[0].firstMutation.afterPromoGate
		afterProjection:     _agentflowRun.plan.nodes[0].firstMutation.afterProjection
		insideMutationScope: _agentflowRun.plan.nodes[0].firstMutation.insideMutationScope
	}
}
_agentflowManifestNode: {
	mutationPolicy: _agentflowRun.manifest.domainNodes[0].mutationPolicy
	promoGate: {
		valid: _agentflowRun.manifest.domainNodes[0].promoGate.valid
	}
	projection: {
		exportedBeforeMutation:  _agentflowRun.manifest.domainNodes[0].projection.exportedBeforeMutation
		acceptedBeforeMutation:  _agentflowRun.manifest.domainNodes[0].projection.acceptedBeforeMutation
		projectedBeforeMutation: _agentflowRun.manifest.domainNodes[0].projection.projectedBeforeMutation
		mutationScopeDerived:    _agentflowRun.manifest.domainNodes[0].projection.mutationScopeDerived
		mutationScope:           _agentflowRun.manifest.domainNodes[0].projection.mutationScope
	}
	firstMutation: {
		afterPromoGate:                  _agentflowRun.manifest.domainNodes[0].firstMutation.afterPromoGate
		afterProjection:                 _agentflowRun.manifest.domainNodes[0].firstMutation.afterProjection
		insideMutationScope:             _agentflowRun.manifest.domainNodes[0].firstMutation.insideMutationScope
		mutationObservedAfterProjection: _agentflowRun.manifest.domainNodes[0].firstMutation.mutationObservedAfterProjection
	}
}

goodGitCommitMutation: git.#GitCommitAdmission & {
	intent: {
		tool:      "git_commit"
		objective: _worktree.objective
		targetPaths: [
			"cue/contracts/git/mutation.cue",
			"cue/contracts/git/fixtures/mutation.cue",
		]
	}
	repo:                  _repo
	worktree:              _worktree
	worktreeTopology:      _topology
	agentflowRun:          _agentflowRun
	agentflowNode:         _agentflowNode
	agentflowManifestNode: _agentflowManifestNode
	evidence:              _evidence
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
	commit: {
		message: "Add Git mutation admission invariant"
		sha:     "def5678"
	}
}

badMissingInvalidPreMutationGate: git.#RejectedGitMutationCandidate & {
	accepted: false
	candidate: {
		intent: goodGitCommitMutation.intent
		agentflowNode: {
			mutationPolicy: "scoped"
			promoGate: valid: false
			projection: {
				exported:             true
				accepted:             true
				mutationScopeDerived: true
				mutationScope: ["cue/contracts/git/mutation.cue"]
			}
			firstMutation: {
				afterPromoGate:      true
				afterProjection:     true
				insideMutationScope: true
			}
		}
	}
	violations: [
		"agentflow promoGate.valid is not true.",
		"agentflow promoGate evidence was not generated or CUE-vetted.",
	]
	rationale: "Git mutation admission consumes agentflow accepted mutating node evidence; an invalid pre-mutation gate cannot satisfy that contract."
}

badProjectionNotAccepted: git.#RejectedGitMutationCandidate & {
	accepted: false
	candidate: {
		intent: goodGitCommitMutation.intent
		agentflowNode: {
			mutationPolicy: "scoped"
			promoGate: valid: true
			projection: {
				exported:             true
				accepted:             false
				mutationScopeDerived: true
				mutationScope: ["cue/contracts/git/mutation.cue"]
			}
			firstMutation: {
				afterPromoGate:      true
				afterProjection:     true
				insideMutationScope: true
			}
		}
	}
	violations: [
		"agentflow projection.accepted is not true.",
	]
	rationale: "Prompt intent and Git state cannot authorize mutation when the selected projection was not accepted."
}

badMutationScopeNotProjectionDerived: git.#RejectedGitMutationCandidate & {
	accepted: false
	candidate: {
		intent: goodGitCommitMutation.intent
		agentflowNode: {
			mutationPolicy: "scoped"
			promoGate: valid: true
			projection: {
				exported:             true
				accepted:             true
				mutationScopeDerived: false
				mutationScope: []
			}
			firstMutation: {
				afterPromoGate:      true
				afterProjection:     true
				insideMutationScope: true
			}
		}
	}
	violations: [
		"agentflow projection.mutationScopeDerived is not true.",
		"agentflow projection.mutationScope is empty.",
	]
	rationale: "Git mutation admission requires a projection-derived mutation scope from accepted agentflow evidence."
}

badFirstMutationBeforeGate: git.#RejectedGitMutationCandidate & {
	accepted: false
	candidate: {
		intent: goodGitCommitMutation.intent
		agentflowNode: {
			mutationPolicy: "scoped"
			promoGate: valid: true
			projection: {
				exported:             true
				accepted:             true
				mutationScopeDerived: true
				mutationScope: ["cue/contracts/git/mutation.cue"]
			}
			firstMutation: {
				afterPromoGate:      false
				afterProjection:     false
				insideMutationScope: false
			}
		}
	}
	violations: [
		"firstMutation.afterPromoGate is not true.",
		"firstMutation.afterProjection is not true.",
		"firstMutation.insideMutationScope is not true.",
	]
	rationale: "Mutation observed before agentflow promotion/projection acceptance cannot satisfy Git mutation admission."
}

badUnadmittedWorktree: git.#RejectedGitMutationCandidate & {
	accepted: false
	candidate: {
		intent: goodGitCommitMutation.intent
		worktree: {
			id:       "primary-dotfiles"
			path:     "/home/_404/src/dotfiles"
			role:     "primary"
			repoRoot: "/home/_404/src/dotfiles"
			head:     _repo.head
			admission: {
				allowed: false
				source:  "explicit-repo"
				proof:   "missing worktree admission proof"
			}
			state: _worktree.state
			invariants: {
				pathBoundaryChecked: false
				gitDirMayBeFile:     false
				noSiblingScan:       false
			}
		}
	}
	violations: [
		"worktree.admission.allowed is not true.",
		"worktree path boundary and .git file/directory handling were not proven.",
		"noSiblingScan invariant is not true.",
	]
	rationale: "Git mutation admission requires an admitted worktree and mandatory worktree topology evidence."
}
