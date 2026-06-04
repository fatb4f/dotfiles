package fixtures

import gitmcp "github.com/fatb4f/dotfiles/cue/contracts/git/projections"

mcpWorktreeBad: gitmcp.#RejectedMCPEvidenceProjection & {
	accepted:             false
	classification:       "bad-as-data"
	exportShouldSucceed:  true
	validationShouldFail: false
	candidate: {
		source: {
			mcpServer: "git-mcp-server"
			repoPath:  "/home/_404/src/dotfiles"
		}
		facts: {
			repo: {
				root:  "/home/_404/src/dotfiles"
				state: "clean"
			}
			status: {
				repositoryState: "dirty"
				worktreeState: {
					clean:       true
					hasStaged:   false
					hasUnstaged: false
					conflicted:  false
				}
			}
			worktrees: {
				worktrees: [
					{
						path: "/home/_404/src/frame"
						admission: {
							allowed: true
							source:  "sibling-worktree"
						}
						invariants: {
							pathBoundaryChecked: false
							noSiblingScan:       false
						}
					},
				]
			}
		}
	}
	violations: [
		"git_status projection claims repository state dirty while worktree state claims clean.",
		"git_worktree_list candidate admits an unselected sibling path.",
		"worktree admission lacks path-boundary and no-sibling-scan proof.",
	]
	rationale: "This fixture is rejected data. It must export with accepted=false so evidence review can inspect violations; it is not an invalid CUE package."
}
