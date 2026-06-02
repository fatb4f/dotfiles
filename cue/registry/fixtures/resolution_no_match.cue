package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

noMatchResolution: reg.#RegistryResolution & {
	registry: reg.registry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/does-not-exist.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}
