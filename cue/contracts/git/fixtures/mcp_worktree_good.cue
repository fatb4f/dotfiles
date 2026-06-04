package fixtures

import (
	git "github.com/fatb4f/dotfiles/cue/contracts/git"
	gitmcp "github.com/fatb4f/dotfiles/cue/contracts/git/projections"
)

mcpWorktreeGood: gitmcp.#MCPGitEvidenceProjection & {
	source: {
		mcpServer: "git-mcp-server"
		repoPath:  "/home/_404/src/dotfiles"
	}

	facts: {
		repo: {
			root:   "/home/_404/src/dotfiles"
			gitDir: "/home/_404/src/dotfiles/.git"
			head: {
				name: "main"
				sha:  "d15a5b25a6af566bae428afab3e09e8c4a91e940"
				kind: "branch"
			}
			defaultRef: "main"
			state:      "clean"
		}
		status: {
			repositoryState: "clean"
			worktreeState: {
				clean:       true
				hasStaged:   false
				hasUnstaged: false
				conflicted:  false
			}
			evidence: {
				tool:     "git_status"
				command:  "git_status(repo_path=/home/_404/src/dotfiles)"
				exitCode: 0
				stdout:   "On branch main\nYour branch is up to date with 'origin/main'.\n\nnothing to commit, working tree clean\n"
				observed: true
			}
		}
		diffs: {
			unstaged: {
				tool:     "git_diff_unstaged"
				command:  "git_diff_unstaged(repo_path=/home/_404/src/dotfiles)"
				exitCode: 0
				stdout:   ""
				observed: true
			}
			staged: {
				tool:     "git_diff_staged"
				command:  "git_diff_staged(repo_path=/home/_404/src/dotfiles)"
				exitCode: 0
				stdout:   ""
				observed: true
			}
		}
		worktrees: {
			evidence: {
				tool:     "git_worktree_list"
				command:  "git_worktree_list(repo_path=/home/_404/src/dotfiles)"
				exitCode: 0
				stdout:   "/home/_404/src/dotfiles  d15a5b2 [main]\n"
				observed: true
			}
			worktrees: [
				{
					id:        "primary-dotfiles"
					path:      "/home/_404/src/dotfiles"
					role:      "primary"
					repoRoot:  "/home/_404/src/dotfiles"
					head:      facts.repo.head
					objective: "Bind Git MCP observations to the typed Git evidence contract."
					inputs: [
						"cue/contracts/git/projections/mcp_evidence.cue",
						"cue/contracts/git/fixtures/mcp_worktree_good.cue",
						"cue/contracts/git/fixtures/mcp_worktree_bad.cue",
					]
					admission: {
						allowed: true
						source:  "explicit-repo"
						proof:   "git_worktree_list observed the selected repository path"
					}
					state: facts.status.worktreeState
					invariants: {
						pathBoundaryChecked: true
						gitDirMayBeFile:     true
						noSiblingScan:       true
					}
				},
			]
		}
	}
}

_mcpWorktreeGoodContract: git.#GitContract & mcpWorktreeGood.contract
