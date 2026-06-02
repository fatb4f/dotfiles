package workspace

import agentnode "github.com/fatb4f/dotfiles/cue/agentnode"

node: agentnode.#AgentNode & {
	schemaVersion: "agentNode.v1"

	node: {
		id:     "workspace"
		domain: "terminal-compositor-editor"
		root:   "nodes/workspace"
	}

	discovery: {
		keywords: [
			{
				term:   "wezterm"
				kind:   "tool"
				weight: 9
				mapsToPatterns: ["wezterm.workspace"]
			},
			{
				term:   "smart-splits"
				kind:   "artifact"
				weight: 10
				mapsToPatterns: ["nvim.smart-splits"]
			},
			{
				term:   "workspace"
				kind:   "primary"
				weight: 8
				mapsToPatterns: [
					"wezterm.workspace",
					"nvim.smart-splits",
				]
			},
		]

		aliases: {
			"terminal workspace": ["wezterm", "mux", "pane"]
			"editor pane":        ["neovim", "smart-splits"]
		}

		negative: [
			"recursive AGENTS.md sweep",
			"full chezmoi scan",
			"unbounded rg --files",
		]
	}

	authority: {
		taskPatterns: [
			{
				id:    "wezterm.workspace"
				path:  "nodes/workspace/patterns/wezterm_workspace.cue"
				stage: "plan"
				rationale: "Workspace tasks mentioning wezterm should load only the wezterm workspace primitive."
				owns: [
					"nodes/workspace/patterns/wezterm_workspace.cue",
				]
				requires: {
					validations: [
						"cue vet ./cue/agentnode/... ./nodes/workspace/...",
					]
					projections: [
						"workspace.rootSelectionResponse",
					]
				}
			},
			{
				id:    "nvim.smart-splits"
				path:  "nodes/workspace/patterns/nvim_smart_splits.cue"
				stage: "verify"
				rationale: "Workspace tasks mentioning smart-splits should load only the Neovim split integration primitive."
				owns: [
					"nodes/workspace/patterns/nvim_smart_splits.cue",
				]
				requires: {
					skills: [
						"neovim",
					]
					validations: [
						"cue vet ./cue/agentnode/... ./nodes/workspace/...",
					]
					projections: [
						"workspace.rootSelectionResponse",
					]
				}
			},
		]

		forbiddenLoads: [
			"chezmoi/**",
			"**/AGENTS.md recursive",
			"** via unbounded rg --files",
		]
	}

	workflow: {
		requires: {
			validations: [
				"cue vet ./cue/agentnode/... ./nodes/workspace/...",
			]
			fixtures: [
				"workspace.boundedDiscoveryFixture",
			]
			projections: [
				"workspace.rootSelectionResponse",
				"workspace.projectedPrompt",
			]
		}

		closeout: [
			"record selected pattern IDs",
			"record loaded files",
			"record forbidden loads avoided",
		]
	}
}
