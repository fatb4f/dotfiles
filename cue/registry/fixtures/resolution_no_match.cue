package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

noMatchResolution: reg.#RegistryResolution & {
	registry: reg.registry
	query: {
		path:           "unrelated/path/file.txt"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}
