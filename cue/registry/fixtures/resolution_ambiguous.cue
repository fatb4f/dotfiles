package fixtures

import reg "github.com/fatb4f/dotfiles/cue/registry"

ambiguousRegistry: reg.#DotfilesRegistry & {
	nodes: {
		weztermConfig: {
			id:          "wezterm-config"
			primaryPath: "chezmoi/private_dot_config/wezterm"
			paths: [
				"chezmoi/private_dot_config/wezterm/wezterm.lua",
				"chezmoi/private_dot_config/wezterm/modules/keys.lua",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectWeztermConfig"
			allowedRoutes: ["inspectWeztermConfig"]
			forbiddenRoutes: []
			validationGates: []
			maxResults:  20
			tokenBudget: 2000
		}

		weztermModulesConfig: {
			id:          "wezterm-modules-config"
			primaryPath: "chezmoi/private_dot_config/wezterm/modules"
			paths: [
				"chezmoi/private_dot_config/wezterm/modules/keys.lua",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectWeztermModulesConfig"
			allowedRoutes: ["inspectWeztermModulesConfig"]
			forbiddenRoutes: []
			validationGates: []
			maxResults:  10
			tokenBudget: 1000
		}
	}

	routes: {
		inspectWeztermConfig: {
			id:     "inspect-wezterm-config"
			intent: "inspect_config"
			appliesTo: ["wezterm-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/wezterm"
				mode:        "literal"
				max_results: 40
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      6000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectWeztermModulesConfig: {
			id:     "inspect-wezterm-modules-config"
			intent: "inspect_config"
			appliesTo: ["wezterm-modules-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/wezterm/modules"
				mode:        "literal"
				max_results: 10
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      1000
			allowGenerated: false
			allowLegacy:    false
		}
	}
}

ambiguousResolution: reg.#RegistryResolution & {
	registry: ambiguousRegistry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}
