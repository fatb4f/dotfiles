package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

goodGeneratedAllowed: reg.#ProjectedSelection & {
	selection: {
		registry: reg.registry
		query: {
			path:           "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
			objective:      "inspect_generated"
			allowGenerated: true
			allowLegacy:    false
		}
	}
	projected: reg.#ExecutableMCPToolRequest & {
		started_at: "2026-06-02T00:00:00Z"
	}
}
