package workspace

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.workspace"
	kind: "repo"
	namespace: ["dotfiles"]
	name: "workspace"

	surfaces: {
		root: {
			kind: "filesystem"
			path: "."
		}
		rootContract: {
			kind: "config"
			path: "AGENTS.cue"
		}
	}

	relations: [
		{
			type:   "uses"
			target: "contracts.architecture"
		},
		{
			type:   "observes"
			target: "git-mcp-server"
		},
	]

	patternRefs: [
		"workspace_entity_update",
		"git_closeout",
	]

	contractRefs: [
		"contracts.architecture",
		"contracts.git.evidence",
	]
}
