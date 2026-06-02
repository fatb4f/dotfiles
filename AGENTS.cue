package dotfiles

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

rootAgentContract: agentnode.#RootIndex & {
	schemaVersion: "agentNode.rootIndex.v1"

	root: {
		id:   "dotfiles-root"
		path: "."
	}

	contracts: [
		{
			nodeID: "workspace"
			path:   "nodes/workspace/AGENTS.cue"
			root:   "nodes/workspace"
		},
	]

	operations: [
		"agentnode.searchKeywords",
		"agentnode.selectPatterns",
		"agentnode.readSelectedPatterns",
		"agentnode.projectWorkflow",
	]
}
