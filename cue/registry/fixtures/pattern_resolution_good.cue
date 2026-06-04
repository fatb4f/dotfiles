package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

patternResolutionGood: reg.#PatternResolution & {
	query: {
		objective: "update repo-local entity model"
		entities: [
			"dotfiles.workspace",
		]
		paths: [
			"cue/nodes/dotfiles/workspace/node.cue",
		]
		taskHints: [
			"entity-modeling",
		]
	}

	candidates: [
		{
			id:         "workspace_entity_update"
			patternRef: "github.com/fatb4f/dotfiles/cue/patterns:workspaceEntityUpdate"
			entities: [
				"dotfiles.workspace",
				"dotfiles.chezmoi",
				"dotfiles.shell-wrap",
			]
			keywords: [
				"workspace",
				"entity",
				"nodes",
			]
		},
	]

	selected: candidates
	status:   "selected"
}
