package impl

#DotfilesNvimQoLComponent: close({
	id:             #KebabIdentifier
	implementation: #NonEmptyString
	layer:          "plugin-graph" | "topology" | "nav" | "tooling" | "lang" | "format" | "lint" | "ai"
	authority:      "owner" | "projection" | "adapter"
	admits:         [...#NonEmptyString] & [_, ...]
	rejects:        [...#NonEmptyString] & [_, ...]
})

#DotfilesNvimQoLSurface: close({
	id:          #KebabIdentifier
	role:        #NonEmptyString
	constraints: [...#NonEmptyString] & [_, ...]
	components:  [...#DotfilesNvimQoLComponent] & [_, ...]
	forbids:     [...#NonEmptyString] & [_, ...]
	predicates: close({
		[string]: #NonEmptyString
	})
})

dotfilesNvimQoLBlockSlice: #DotfilesNvimQoLSurface & {
	id:   "dotfiles-nvim-qol-block-slice"
	role: "materialized Neovim runtime ownership contract"

	constraints: [
		"LazyVim owns the Neovim plugin graph through lazy.nvim",
		"WezTerm owns project and session topology",
		"Snacks owns editor-local file exploration",
		"system PATH owns language executable discovery",
		"gopls owns Go language intelligence",
		"Conform owns formatter dispatch",
		"nvim-lint owns external lint projection",
		"CodeCompanion delegates Codex ACP interaction to codex-acp",
	]

	components: [
		{
			id:             "lazyvim-plugin-graph"
			implementation: "lazy.nvim with LazyVim imports and repo-local plugin specs"
			layer:          "plugin-graph"
			authority:      "owner"
			admits:         ["LazyVim defaults", "LazyVim extras", "repo-local plugin specs"]
			rejects:        ["native vim.pack supply", "parallel plugin manager authority", "Mason language-tool authority"]
		},
		{
			id:             "wezterm-topology"
			implementation: "WezTerm project registry and sessionizer"
			layer:          "topology"
			authority:      "owner"
			admits:         ["project identity", "project roots", "workspace selection", "session lifecycle"]
			rejects:        ["editor buffer ownership", "editor-local file exploration"]
		},
		{
			id:             "snacks-explorer"
			implementation: "https://github.com/folke/snacks.nvim"
			layer:          "nav"
			authority:      "owner"
			admits:         ["editor-local file browsing", "project-root exploration", "cwd exploration", "netrw replacement"]
			rejects:        ["project registry ownership", "workspace selection", "session persistence"]
		},
		{
			id:             "system-path-tools"
			implementation: "system PATH populated by the zsh environment"
			layer:          "tooling"
			authority:      "owner"
			admits:         ["externally installed language servers", "formatters", "linters", "debug adapters"]
			rejects:        ["Mason-managed executables", "Neovim-local executable installation"]
		},
		{
			id:             "gopls"
			implementation: "golang.org/x/tools/gopls resolved from PATH"
			layer:          "lang"
			authority:      "owner"
			admits:         ["Go language intelligence", "Go diagnostics", "Go code navigation"]
			rejects:        ["Mason installation", "duplicate Go language-server authority"]
		},
		{
			id:             "conform"
			implementation: "https://github.com/stevearc/conform.nvim"
			layer:          "format"
			authority:      "owner"
			admits:         ["formatter registry", "formatter dispatch", "format-on-save policy"]
			rejects:        ["undeclared formatter dispatch", "language-tool installation"]
		},
		{
			id:             "nvim-lint"
			implementation: "https://github.com/mfussenegger/nvim-lint"
			layer:          "lint"
			authority:      "owner"
			admits:         ["external linter dispatch", "vim.diagnostic projection", "filetype-to-linter mapping"]
			rejects:        ["LSP diagnostic duplication", "language-tool installation"]
		},
		{
			id:             "codecompanion-codex-acp"
			implementation: "CodeCompanion codex ACP adapter through codex-acp"
			layer:          "ai"
			authority:      "owner"
			admits:         ["Codex ACP interaction", "chat-gpt authentication", "codex-acp resolved from PATH"]
			rejects:        ["direct API-key authentication", "alternate Codex ACP command ownership"]
		},
	]

	forbids: [
		"native vim.pack plugin graph authority",
		"xplr-owned editor-local file exploration",
		"Neovim project or session topology authority",
		"Snacks project or session topology authority",
		"Mason-managed language executables",
		"Neovim-local language executable installation",
		"duplicate Go language-server authority",
		"formatter dispatch outside Conform",
		"external lint projection outside nvim-lint",
		"CodeCompanion Codex ACP interaction bypassing codex-acp",
		"generated artifacts as authority",
	]

	predicates: {
		"lazyvim-plugin-graph":       "config/lazy.lua bootstraps lazy.nvim, imports LazyVim and extras, then imports repo-local plugin specs"
		"wezterm-topology-authority": "WezTerm project registry and sessionizer own project identity, roots, workspaces, and session lifecycle"
		"snacks-explorer-authority":  "Snacks explorer owns editor-local project-root and cwd exploration without selecting or persisting sessions"
		"system-path-tool-authority": "language executables are installed outside Neovim and resolved through the zsh-projected system PATH"
		"gopls-go-intelligence":      "the LazyVim Go extra configures gopls while system-tooling disables Mason ownership"
		"conform-format-dispatch":    "Conform is materialized in the LazyVim graph as formatter dispatch authority"
		"nvim-lint-projection":       "nvim-lint dispatches external linters and projects their results through vim.diagnostic"
		"codecompanion-codex-acp":    "CodeCompanion resolves codex-acp from PATH and selects chat-gpt authentication for the Codex ACP adapter"
	}
}

_negativeBottomChecks: {
	"native-vim-pack-authority-rejected":       "bottom"
	"xplr-editor-exploration-rejected":         "bottom"
	"neovim-topology-authority-rejected":       "bottom"
	"snacks-topology-authority-rejected":       "bottom"
	"mason-language-tool-authority-rejected":   "bottom"
	"duplicate-go-language-server-rejected":    "bottom"
	"formatter-dispatch-bypass-rejected":       "bottom"
	"external-lint-projection-bypass-rejected": "bottom"
	"codex-acp-bypass-rejected":                "bottom"
}

dotfilesNvimQoLValidationPlan: {
	kind: "validation-plan"
	commands: [
		#CueExportExpectedSuccess & {
			expr: "dotfilesNvimQoLBlockSlice"
		},
	]
	assertions: {
		"ownership-graph-materialized": {
			id:          "ownership-graph-materialized"
			mode:        "preserves"
			family:      "assertion"
			description: "The contract preserves the implemented Neovim runtime ownership graph"
			expected:    dotfilesNvimQoLBlockSlice.components
			proof:       dotfilesNvimQoLBlockSlice.predicates
			proofStatus: "proven"
		}
		"legacy-authorities-rejected": {
			id:          "legacy-authorities-rejected"
			mode:        "forbids"
			family:      "assertion"
			description: "Stale native vim.pack, xplr editor, and gated-adapter authorities remain outside the materialized runtime contract"
			expected:    dotfilesNvimQoLBlockSlice.forbids
			proof:       _negativeBottomChecks
			proofStatus: "proven"
		}
	}
}

dotfilesNvimQoLCompletionReport: {
	kind: "completion-report-contract"
	requiredSections: [
		"summary",
		"manifest workflow",
		"runtime ownership graph",
		"LazyVim plugin graph",
		"WezTerm topology authority",
		"Snacks editor-local exploration",
		"system PATH language tooling",
		"gopls language intelligence",
		"Conform formatter dispatch",
		"nvim-lint projection",
		"CodeCompanion codex-acp interaction",
		"negative checks",
		"validation",
		"evidence",
	]
	expected: {
		state: "dotfiles-nvim-qol-block-slice"
		assertions: {
			"ownership-graph-materialized": true
			"legacy-authorities-rejected":  true
		}
		fixtures: {
			for fixture, _ in _negativeBottomChecks {
				"\(fixture)": true
			}
		}
		subsumptions: {}
		commands:     dotfilesNvimQoLValidationPlan.commands
		evidence: {
			"lazyvim-config":         true
			"wezterm-workspaces":     true
			"snacks-explorer-config": true
			"system-path-config":     true
			"system-tooling-config":  true
			"codecompanion-config":   true
		}
	}
}
