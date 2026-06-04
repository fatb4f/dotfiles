package fixtures

import git "github.com/fatb4f/dotfiles/cue/contracts/git"

good: git.#GitContract & {
	repo: {
		root:   "/home/_404/src/dotfiles"
		gitDir: "/home/_404/src/dotfiles/.git"
		head: {
			name: "main"
			sha:  "abc1234"
			kind: "branch"
		}
		defaultRef: "main"
		state:      "clean"
	}

	worktrees: [
		{
			id:        "primary-dotfiles"
			path:      "/home/_404/src/dotfiles"
			role:      "primary"
			repoRoot:  "/home/_404/src/dotfiles"
			head:      good.repo.head
			objective: "Re-implement git.cue as a typed Git contract while preserving the domain card."
			inputs: [
				"cue/patterns/domain/git.cue",
				"cue/contracts/git/*.cue",
			]
			admission: {
				allowed: true
				source:  "explicit-repo"
				proof:   "git status --short observed from selected repository root"
			}
			state: {
				clean:       true
				hasStaged:   false
				hasUnstaged: false
				conflicted:  false
			}
			invariants: {
				pathBoundaryChecked: true
				gitDirMayBeFile:     true
				noSiblingScan:       true
			}
		},
		{
			id:        "failure-repro"
			path:      "/home/_404/src/dotfiles-failure"
			role:      "failure-repro"
			repoRoot:  "/home/_404/src/dotfiles"
			head:      good.repo.head
			objective: good.worktrees[0].objective
			inputs:    good.worktrees[0].inputs
			admission: {
				allowed: true
				source:  "sibling-worktree"
				proof:   "git worktree list observed and path boundary checked"
			}
			state: {
				clean:       true
				hasStaged:   false
				hasUnstaged: false
				conflicted:  false
			}
			invariants: {
				pathBoundaryChecked: true
				gitDirMayBeFile:     true
				noSiblingScan:       true
			}
		},
		{
			id:        "repair-proof"
			path:      "/home/_404/src/dotfiles-repair"
			role:      "repair-proof"
			repoRoot:  "/home/_404/src/dotfiles"
			head:      good.repo.head
			objective: good.worktrees[0].objective
			inputs:    good.worktrees[0].inputs
			admission: {
				allowed: true
				source:  "sibling-worktree"
				proof:   "git worktree list observed and path boundary checked"
			}
			state: {
				clean:       true
				hasStaged:   false
				hasUnstaged: false
				conflicted:  false
			}
			invariants: {
				pathBoundaryChecked: true
				gitDirMayBeFile:     true
				noSiblingScan:       true
			}
		},
		{
			id:        "proof-stack"
			path:      "/home/_404/src/dotfiles-proof"
			role:      "proof-stack"
			repoRoot:  "/home/_404/src/dotfiles"
			head:      good.repo.head
			objective: good.worktrees[0].objective
			inputs:    good.worktrees[0].inputs
			admission: {
				allowed: true
				source:  "sibling-worktree"
				proof:   "git worktree list observed and path boundary checked"
			}
			state: {
				clean:       true
				hasStaged:   false
				hasUnstaged: false
				conflicted:  false
			}
			invariants: {
				pathBoundaryChecked: true
				gitDirMayBeFile:     true
				noSiblingScan:       true
			}
		},
	]

	worktreeTopology: {
		id:        "same-head-isolated-proof"
		head:      good.repo.head
		objective: good.worktrees[0].objective
		inputs:    good.worktrees[0].inputs
		worktrees: good.worktrees
		invariants: {
			sameHEAD:        true
			sameObjective:   true
			sameInputs:      true
			isolatedPaths:   true
			noSiblingScan:   true
			gitDirMayBeFile: true
		}
	}

	patchStack: {
		id:   "typed-git-contract-example"
		base: good.repo.head
		head: {
			sha:  "def5678"
			kind: "commit"
		}
		patches: [
			{
				id: "introduce-git-contract"
				commit: {
					sha:  "def5678"
					kind: "commit"
				}
				parent: good.repo.head
				role:   "introduce-contract"
				scope: {
					files: [
						"cue/contracts/git/schema.cue",
						"cue/contracts/git/worktree.cue",
						"cue/contracts/git/patch_stack.cue",
						"cue/contracts/git/evidence.cue",
					]
					domains: ["git"]
				}
				evidence: {
					statusBefore: "git status --short"
					diff:         "git diff"
					statusAfter:  "git status --short"
					cue: [
						{
							command:  "cue vet ./cue/contracts/git/..."
							exitCode: 0
							stdout:   ""
							observed: true
						},
					]
				}
				admissible: true
			},
		]
		transitions: [
			{
				from:   good.repo.head
				to:     good.patchStack.head
				patch:  good.patchStack.patches[0]
				result: "admitted"
			},
		]
		invariants: {
			ordered:             true
			parentChainValid:    true
			eachPatchAdmissible: true
			finalTreeValid:      true
			noScopeInversion:    true
		}
	}

	evidence: {
		statusShort: {
			command:  "git status --short"
			exitCode: 0
			stdout:   ""
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
			stdout:   ""
			observed: true
		}
		artifacts: [
			{
				kind:     "status-short"
				source:   "git status --short"
				observed: true
			},
			{
				kind:     "diff-staged"
				source:   "git diff --staged"
				observed: true
			},
			{
				kind:     "diff"
				source:   "git diff"
				observed: true
			},
		]
	}

	gates: {
		preCloseout: {
			statusObserved: true
			diffObserved:   true
		}
		worktreeGate: {
			worktreeListObserved: true
			admissionChecked:     true
			noUnauthorizedPath:   true
		}
	}
}
