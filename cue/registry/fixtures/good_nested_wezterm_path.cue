package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

goodNestedWezterm: reg.#ProjectedSelection & {
	selection: {
		registry: reg.registry
		query: {
			path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
			objective:      "inspect_config"
			allowGenerated: false
			allowLegacy:    false
		}
	}
	projected: reg.#ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}
