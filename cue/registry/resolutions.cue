package registry

weztermResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/wezterm.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}

nestedWeztermResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}

generatedAllowedResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
		objective:      "inspect_generated"
		allowGenerated: true
		allowLegacy:    false
	}
}

legacyAllowedResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
		objective:      "inspect_legacy"
		allowGenerated: false
		allowLegacy:    true
	}
}

generatedBlockedResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
		objective:      "inspect_generated"
		allowGenerated: false
		allowLegacy:    false
	}
}

legacyBlockedResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
		objective:      "inspect_legacy"
		allowGenerated: false
		allowLegacy:    false
	}
}

noMatchResolution: #RegistryResolution & {
	registry: exampleRegistry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/does-not-exist.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}

ambiguousRegistry: #DotfilesRegistry & {
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

ambiguousResolution: #RegistryResolution & {
	registry: ambiguousRegistry
	query: {
		path:           "chezmoi/private_dot_config/wezterm/modules/keys.lua"
		objective:      "inspect_config"
		allowGenerated: false
		allowLegacy:    false
	}
}
