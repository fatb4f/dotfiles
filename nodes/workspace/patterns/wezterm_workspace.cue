package workspace

weztermWorkspacePattern: {
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
