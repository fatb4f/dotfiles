package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

good: reg.#ProjectedSelection & {
	selection: {
		registry: reg.registry
		query: {
			path:       "chezmoi/private_dot_config/wezterm/wezterm.lua"
			objective:  "inspect_config"
			allowGenerated: false
			allowLegacy:    false
		}
	}
	projected: {
		started_at: "2026-06-02T00:00:00Z"
	}
}
