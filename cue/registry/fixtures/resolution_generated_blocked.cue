package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

generatedBlockedResolution: reg.#RegistryResolution & {
	registry: reg.registry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
		objective:      "inspect_generated"
		allowGenerated: false
		allowLegacy:    false
	}
}
