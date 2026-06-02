package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

legacyBlockedResolution: reg.#RegistryResolution & {
	registry: reg.registry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
		objective:      "inspect_legacy"
		allowGenerated: false
		allowLegacy:    false
	}
}
