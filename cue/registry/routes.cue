package registry

registry: {
	routes: {
		inspectCuePolicy: {
			id:     "inspect-cue-policy"
			intent: "inspect_policy"
			appliesTo: ["cue-policy"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "cue.mods/hookrail"
				mode:        "literal"
				max_results: 60
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      8000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectDotctlAdapter: {
			id:     "inspect-dotctl-adapter"
			intent: "inspect_adapter"
			appliesTo: ["dotctl-adapter"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "shell-wrap/src/hookrail"
				mode:        "literal"
				max_results: 80
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      6000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectBootstrap: {
			id:     "inspect-bootstrap"
			intent: "inspect_bootstrap"
			appliesTo: ["bootstrap"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/dot_local/share/codex/tools/hookrail"
				mode:        "literal"
				max_results: 40
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      5000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectHyprlandConfig: {
			id:     "inspect-hyprland-config"
			intent: "inspect_config"
			appliesTo: ["hyprland-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/hypr"
				mode:        "literal"
				max_results: 40
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      6000
			allowGenerated: false
			allowLegacy:    false
		}

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

		inspectZshConfig: {
			id:     "inspect-zsh-config"
			intent: "inspect_config"
			appliesTo: ["zsh-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/zsh"
				mode:        "literal"
				max_results: 60
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      7000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectNvimConfig: {
			id:     "inspect-nvim-config"
			intent: "inspect_config"
			appliesTo: ["nvim-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/nvim"
				mode:        "literal"
				max_results: 80
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      8000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectGeneratedProjections: {
			id:     "inspect-generated-projections"
			intent: "inspect_generated"
			appliesTo: ["generated-projections"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/systemd/user/user.manifest"
				mode:        "literal"
				max_results: 30
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      3000
			allowGenerated: true
			allowLegacy:    false
		}

		inspectYaziConfig: {
			id:     "inspect-yazi-config"
			intent: "inspect_config"
			appliesTo: ["yazi-config"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/yazi"
				mode:        "literal"
				max_results: 50
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      5000
			allowGenerated: false
			allowLegacy:    false
		}

		inspectLegacySessionSurfaces: {
			id:     "inspect-legacy-session-surfaces"
			intent: "inspect_legacy"
			appliesTo: ["legacy-session-surfaces"]
			server_cmd: ["mcp-ripgrep"]
			tool_name: "search"
			tool_args: {
				path:        "chezmoi/private_dot_config/systemd/user/user.manifest"
				mode:        "literal"
				max_results: 20
			}
			cwd:            "."
			timeout_ms:     15000
			maxTokens:      2000
			allowGenerated: false
			allowLegacy:    true
		}
	}
}
