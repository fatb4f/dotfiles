package registry

registry: #DotfilesRegistry & {
	nodes: {
		cuePolicy: {
			id:          "cue-policy"
			primaryPath: "cue.mods/hookrail"
			paths: [
				"cue.mods/hookrail/common.cue",
				"cue.mods/hookrail/frame.cue",
				"cue.mods/hookrail/hooks.cue",
				"cue.mods/hookrail/manifest.cue",
				"cue.mods/hookrail/output.cue",
				"cue.mods/hookrail/projection.cue",
			]
			role:    "policy"
			owner:   "frame"
			intent:  "inspect_policy"
			routeID: "inspectCuePolicy"
			allowedRoutes: ["inspectCuePolicy"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "cue-policy-scope"
					kind:   "path_scope"
					detail: "limit inspection to the frame contract layer."
					path:   "cue.mods/hookrail"
				},
				{
					id:     "cue-policy-budget"
					kind:   "budget"
					detail: "keep policy retrieval bounded."
					path:   "cue.mods/hookrail"
				},
			]
			maxResults:  60
			tokenBudget: 8000
		}

		dotctlAdapter: {
			id:          "dotctl-adapter"
			primaryPath: "shell-wrap/src/hookrail"
			paths: [
				"shell-wrap/src/hookrail/src/bashly.yml",
				"shell-wrap/src/hookrail/src/commands/doctor.sh",
				"shell-wrap/src/hookrail/src/commands/hook.sh",
				"shell-wrap/src/hookrail/src/lib/cue.sh",
			]
			role:    "adapter"
			owner:   "shell-wrap"
			intent:  "inspect_adapter"
			routeID: "inspectDotctlAdapter"
			allowedRoutes: ["inspectDotctlAdapter"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "dotctl-adapter-scope"
					kind:   "path_scope"
					detail: "focus on the Bashly adapter surface."
					path:   "shell-wrap/src/hookrail"
				},
			]
			maxResults:  80
			tokenBudget: 6000
		}

		bootstrap: {
			id:          "bootstrap"
			primaryPath: "chezmoi/dot_local/share/codex/tools/hookrail"
			paths: [
				"chezmoi/dot_local/share/codex/tools/hookrail/MANIFEST.md",
				"chezmoi/dot_local/share/codex/tools/hookrail/README.md",
				"chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-doctor",
				"chezmoi/dot_local/share/codex/tools/hookrail/scripts/executable_install-to-codex-home",
			]
			role:    "bootstrap"
			owner:   "chezmoi"
			intent:  "inspect_bootstrap"
			routeID: "inspectBootstrap"
			allowedRoutes: ["inspectBootstrap"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "bootstrap-scope"
					kind:   "path_scope"
					detail: "only the bootstrap and install surface."
					path:   "chezmoi/dot_local/share/codex/tools/hookrail"
				},
			]
			maxResults:  40
			tokenBudget: 5000
		}

		hyprlandConfig: {
			id:          "hyprland-config"
			primaryPath: "chezmoi/private_dot_config/hypr"
			paths: [
				"chezmoi/private_dot_config/hypr/hyprland.lua",
				"chezmoi/private_dot_config/hypr/hypridle.conf",
				"chezmoi/private_dot_config/hypr/hyprlock.conf",
				"chezmoi/private_dot_config/hypr/hyprpaper.conf",
				"chezmoi/private_dot_config/hypr/modules/binds.lua",
				"chezmoi/private_dot_config/hypr/modules/layouts.lua",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectHyprlandConfig"
			allowedRoutes: ["inspectHyprlandConfig"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "hyprland-scope"
					kind:   "path_scope"
					detail: "inspect the Hyprland surface only."
					path:   "chezmoi/private_dot_config/hypr"
				},
			]
			maxResults:  40
			tokenBudget: 6000
		}

		weztermConfig: {
			id:          "wezterm-config"
			primaryPath: "chezmoi/private_dot_config/wezterm"
			paths: [
				"chezmoi/private_dot_config/wezterm/wezterm.lua",
				"chezmoi/private_dot_config/wezterm/wezterm.sh",
				"chezmoi/private_dot_config/wezterm/modules/shell.lua",
				"chezmoi/private_dot_config/wezterm/modules/status.lua",
				"chezmoi/private_dot_config/wezterm/modules/workspaces.lua",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectWeztermConfig"
			allowedRoutes: ["inspectWeztermConfig"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "wezterm-scope"
					kind:   "path_scope"
					detail: "inspect the WezTerm surface only."
					path:   "chezmoi/private_dot_config/wezterm"
				},
			]
			maxResults:  40
			tokenBudget: 6000
		}

		zshConfig: {
			id:          "zsh-config"
			primaryPath: "chezmoi/private_dot_config/zsh"
			paths: [
				"chezmoi/private_dot_config/zsh/dot_zshenv",
				"chezmoi/private_dot_config/zsh/dot_zshrc",
				"chezmoi/private_dot_config/zsh/fn/br",
				"chezmoi/private_dot_config/zsh/fn/la",
				"chezmoi/private_dot_config/zsh/fn/named_dirs_load",
				"chezmoi/private_dot_config/zsh/fn/up",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectZshConfig"
			allowedRoutes: ["inspectZshConfig"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "zsh-scope"
					kind:   "path_scope"
					detail: "inspect the zsh bootstrap and shell init surface."
					path:   "chezmoi/private_dot_config/zsh"
				},
			]
			maxResults:  60
			tokenBudget: 7000
		}

		nvimConfig: {
			id:          "nvim-config"
			primaryPath: "chezmoi/private_dot_config/nvim"
			paths: [
				"chezmoi/private_dot_config/nvim/init.lua",
				"chezmoi/private_dot_config/nvim/lua/config/autocmds.lua",
				"chezmoi/private_dot_config/nvim/lua/config/lazy.lua",
				"chezmoi/private_dot_config/nvim/lua/plugins/core.lua",
				"chezmoi/private_dot_config/nvim/lua/plugins/smart-splits.lua",
				"chezmoi/private_dot_config/nvim/stylua.toml",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectNvimConfig"
			allowedRoutes: ["inspectNvimConfig"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "nvim-scope"
					kind:   "path_scope"
					detail: "inspect the Neovim surface only."
					path:   "chezmoi/private_dot_config/nvim"
				},
			]
			maxResults:  80
			tokenBudget: 8000
		}

		generatedProjections: {
			id:          "generated-projections"
			primaryPath: "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
			paths: [
				"chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md",
				"chezmoi/private_dot_config/systemd/user/user.manifest/README.md",
			]
			role:    "generated"
			owner:   "chezmoi"
			intent:  "inspect_generated"
			routeID: "inspectGeneratedProjections"
			allowedRoutes: ["inspectGeneratedProjections"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "generated-requires-override"
					kind:   "override"
					detail: "generated projection paths require an explicit allowGenerated override."
					path:   "chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md"
				},
			]
			maxResults:  30
			tokenBudget: 3000
		}

		yaziConfig: {
			id:          "yazi-config"
			primaryPath: "chezmoi/private_dot_config/yazi"
			paths: [
				"chezmoi/private_dot_config/yazi/init.lua",
				"chezmoi/private_dot_config/yazi/keymap.toml",
				"chezmoi/private_dot_config/yazi/package.toml",
				"chezmoi/private_dot_config/yazi/theme.toml",
				"chezmoi/private_dot_config/yazi/yazi.toml",
			]
			role:    "config"
			owner:   "dotfiles"
			intent:  "inspect_config"
			routeID: "inspectYaziConfig"
			allowedRoutes: ["inspectYaziConfig"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "yazi-scope"
					kind:   "path_scope"
					detail: "inspect the Yazi config surface only."
					path:   "chezmoi/private_dot_config/yazi"
				},
			]
			maxResults:  50
			tokenBudget: 5000
		}

		legacySessionSurfaces: {
			id:          "legacy-session-surfaces"
			primaryPath: "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
			paths: [
				"chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md",
				"chezmoi/private_dot_config/systemd/user/user.manifest/generated-wants.md",
			]
			role:    "legacy"
			owner:   "chezmoi"
			intent:  "inspect_legacy"
			routeID: "inspectLegacySessionSurfaces"
			allowedRoutes: ["inspectLegacySessionSurfaces"]
			forbiddenRoutes: []
			validationGates: [
				{
					id:     "legacy-requires-override"
					kind:   "override"
					detail: "legacy session surfaces require an explicit allowLegacy override."
					path:   "chezmoi/private_dot_config/systemd/user/user.manifest/session-companions.md"
				},
			]
			maxResults:  20
			tokenBudget: 2000
		}
	}
}
