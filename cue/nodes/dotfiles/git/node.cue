package git

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.git"
	kind: "tool"
	namespace: ["dotfiles"]
	name: "git"

	summary: "Repository state, staging, worktree, and patch-stack evidence"

	surfaces: {
		repository: {
			kind: "filesystem"
			path: "."
		}
		metadata: {
			kind: "filesystem"
			path: ".git/"
		}
	}

	relations: [
		{
			type:   "observes"
			target: "dotfiles.workspace"
		},
		{
			type:   "mutates"
			target: "dotfiles.workspace"
		},
	]

	patternRefs: [
		"git_closeout",
		"generated_cli_change",
	]

	contractRefs: [
		"contracts.git.observation",
		"contracts.git.mutation",
		"contracts.git.worktree",
		"contracts.git.patch_stack",
	]
}
