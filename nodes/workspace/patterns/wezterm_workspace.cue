package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

weztermWorkspacePattern: agentnode.#TaskPatternCard & {
	id: "wezterm.workspace"

	authority: {
		loadableFiles: [
			"nodes/workspace/patterns/wezterm_workspace.cue",
		]
	}

	workflow: {
		stage: "plan"
	}
}
