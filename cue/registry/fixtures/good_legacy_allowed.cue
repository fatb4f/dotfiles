package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

goodLegacyAllowed: reg.#ProjectedSelection & {
	selection: {
		registry: reg.registry
		query: {
			path:           "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
			objective:      "inspect_legacy"
			allowGenerated: false
			allowLegacy:    true
		}
	}
	projected: reg.#ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}
