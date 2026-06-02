package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

bad: reg.#ProjectedSelection & {
	selection: {
		registry: reg.registry
		query: {
			path:      "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
			objective: "inspect_generated"
		}
	}
	projected: {
		started_at: "2026-06-02T00:00:00Z"
	}
}
