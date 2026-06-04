package shellwrap

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.shell-wrap"
	kind: "adapter"
	namespace: ["dotfiles"]
	name: "shell-wrap"

	summary: "shell-wrap and Hookrail command-surface adapter metadata"

	surfaces: {
		source: {
			kind: "filesystem"
			path: "shell-wrap/"
		}
		hookrailAdapter: {
			kind: "filesystem"
			path: "shell-wrap/src/hookrail/"
		}
		bashly: {
			kind: "config"
			path: "shell-wrap/src/hookrail/src/bashly.yml"
		}
	}

	relations: [
		{
			type:   "wraps"
			target: "dotfiles.hookrail"
		},
		{
			type:   "depends-on"
			target: "dotfiles.chezmoi"
		},
	]

	patternRefs: [
		"generated_cli_change",
	]

	contractRefs: [
		"contracts.agentflow.premutation",
		"contracts.git.mutation",
	]
}
