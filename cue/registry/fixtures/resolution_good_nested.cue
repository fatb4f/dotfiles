package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

goodNestedResolution: reg.#RegistryResolution & {
	registry: reg.registry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}
