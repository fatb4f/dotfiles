package workspace

nvimSmartSplitsPattern: {
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
