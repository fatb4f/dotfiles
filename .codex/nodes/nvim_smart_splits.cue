package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

nvimSmartSplitsPattern: agentnode.#TaskPatternCard & {
	id: "nvim.smart-splits"

	authority: {
		loadableFiles: [
			"nodes/workspace/patterns/nvim_smart_splits.cue",
		]
	}

	workflow: {
		stage: "verify"
	}
}
