package dotfilesnodes

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

#DotfilesNode: nodes.#Node & {
	namespace: ["dotfiles", ...string]
}

namespace: {
	id:   "dotfiles"
	kind: "repo-local-entity-namespace"
	root: "cue/nodes/dotfiles"
}
