package projections

import git "github.com/fatb4f/dotfiles/cue/contracts/git"

#MCPGitTool:
	"git_status" |
	"git_diff_unstaged" |
	"git_diff_staged" |
	"git_worktree_list" |
	"git_commit"

#ProjectionMapping: {
	from: #MCPGitTool
	to:   string
}

#MCPCommandObservation: {
	tool:     #MCPGitTool
	command:  string
	exitCode: int
	stdout:   string
	stderr?:  string
	observed: true
}

#MCPStatusProjection: {
	repositoryState: git.#RepositoryState
	worktreeState: {
		clean:       bool
		hasStaged:   bool
		hasUnstaged: bool
		conflicted:  bool
	}
	evidence: #MCPCommandObservation & {
		tool: "git_status"
	}
}

#MCPDiffProjection: {
	unstaged: #MCPCommandObservation & {
		tool: "git_diff_unstaged"
	}
	staged: #MCPCommandObservation & {
		tool: "git_diff_staged"
	}
}

#MCPWorktreeInventoryProjection: {
	evidence: #MCPCommandObservation & {
		tool: "git_worktree_list"
	}
	worktrees: [...git.#AdmittedWorktree]
}

#MCPCommitProjection: {
	sha:     git.#HexSHA
	message: string
	evidence: #MCPCommandObservation & {
		tool: "git_commit"
	}
}

#MCPEvidenceFacts: {
	repo: git.#Repository
	status: #MCPStatusProjection & {
		repositoryState: repo.state
	}
	diffs:     #MCPDiffProjection
	worktrees: #MCPWorktreeInventoryProjection
	commit?:   #MCPCommitProjection
}

#MCPGitEvidenceProjection: {
	accepted: true
	source: {
		mcpServer: "git-mcp-server"
		repoPath:  string
	}

	mappings: [
		{from: "git_worktree_list", to: "#Worktree inventory evidence"},
		{from: "git_status", to: "#Repository.state / #Worktree.state"},
		{from: "git_diff_unstaged", to: "#GitEvidence.diff"},
		{from: "git_diff_staged", to: "#GitEvidence.diffStaged"},
		{from: "git_commit", to: "#Patch.commit / #GitEvidence.commit"},
	]

	facts: #MCPEvidenceFacts

	contract: git.#GitContract & {
		repo: facts.repo
		worktrees: [
			for worktree in facts.worktrees.worktrees {
				worktree & {
					state: facts.status.worktreeState
				}
			},
		]
		worktreeTopology: {
			id:        "mcp-observed-worktree-topology"
			head:      facts.repo.head
			objective: facts.worktrees.worktrees[0].objective
			inputs:    facts.worktrees.worktrees[0].inputs
			worktrees: [
				for worktree in facts.worktrees.worktrees {
					worktree & {
						state: facts.status.worktreeState
					}
				},
			]
			invariants: {
				sameHEAD:        true
				sameObjective:   true
				sameInputs:      true
				isolatedPaths:   true
				noSiblingScan:   true
				gitDirMayBeFile: true
			}
		}
		evidence: {
			statusShort: {
				command:  facts.status.evidence.command
				exitCode: facts.status.evidence.exitCode
				stdout:   facts.status.evidence.stdout
				if facts.status.evidence.stderr != _|_ {
					stderr: facts.status.evidence.stderr
				}
				observed: true
			}
			diff: {
				command:  facts.diffs.unstaged.command
				exitCode: facts.diffs.unstaged.exitCode
				stdout:   facts.diffs.unstaged.stdout
				if facts.diffs.unstaged.stderr != _|_ {
					stderr: facts.diffs.unstaged.stderr
				}
				observed: true
			}
			diffStaged: {
				command:  facts.diffs.staged.command
				exitCode: facts.diffs.staged.exitCode
				stdout:   facts.diffs.staged.stdout
				if facts.diffs.staged.stderr != _|_ {
					stderr: facts.diffs.staged.stderr
				}
				observed: true
			}
			worktrees: {
				command:  facts.worktrees.evidence.command
				exitCode: facts.worktrees.evidence.exitCode
				stdout:   facts.worktrees.evidence.stdout
				if facts.worktrees.evidence.stderr != _|_ {
					stderr: facts.worktrees.evidence.stderr
				}
				observed: true
			}
			if facts.commit != _|_ {
				commit: {
					sha:     facts.commit.sha
					message: facts.commit.message
				}
			}
			artifacts: [
				{kind: "status-short", source: facts.status.evidence.tool, observed: true},
				{kind: "diff", source: facts.diffs.unstaged.tool, observed: true},
				{kind: "diff-staged", source: facts.diffs.staged.tool, observed: true},
				{kind: "worktree-list", source: facts.worktrees.evidence.tool, observed: true},
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
			if facts.commit != _|_ {
				commitGate: {
					stagedDiffReviewed: true
					commitCreated:      true
					commitSHA:          facts.commit.sha
				}
			}
		}
	}
}

#RejectedMCPEvidenceProjection: {
	accepted:             false
	classification:       "bad-as-data"
	exportShouldSucceed:  true
	validationShouldFail: false
	candidate:            _
	violations: [...string]
	rationale: string
}

#MCPProjectionOutcome: #MCPGitEvidenceProjection | #RejectedMCPEvidenceProjection
