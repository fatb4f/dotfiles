package chezmoi

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.chezmoi"
	kind: "tool"
	namespace: ["dotfiles"]
	name: "chezmoi"

	surfaces: {
		source: {
			kind: "filesystem"
			path: "chezmoi/"
		}
		state: {
			kind: "runtime"
			ref:  "chezmoi state"
		}
	}

	relations: [
		{
			type:   "projects-to"
			target: "home-filesystem"
		},
		{
			type:   "configures"
			target: "dotfiles.shell-wrap"
		},
	]

	patternRefs: [
		"workspace_entity_update",
		"generated_cli_change",
	]

	contractRefs: [
		"contracts.git.mutation",
		"contracts.agentflow.premutation",
		"contracts.lifecycle.proof",
	]
}
