package impl

#DotfilesNvimQoLPlugin: close({
	id:        #KebabIdentifier
	plugin:    #NonEmptyString
	layer:     "ui" | "edit" | "nav" | "git" | "lang"
	authority: "projection" | "adapter"
	admits: [...#NonEmptyString] & [_, ...]
	rejects: [...#NonEmptyString] & [_, ...]
	gate?: #NonEmptyString
})

#DotfilesNvimQoLSurface: close({
	id:   #KebabIdentifier
	role: #NonEmptyString
	constraints: [...#NonEmptyString] & [_, ...]
	p0: [...#DotfilesNvimQoLPlugin] & [_, ...]
	p1: [...#DotfilesNvimQoLPlugin]
	forbids: [...#NonEmptyString] & [_, ...]
	predicates: close({
		[string]: #NonEmptyString
	})
})

dotfilesNvimQoLBlockSlice: #DotfilesNvimQoLSurface & {
	id:   "dotfiles-nvim-qol-block-slice"
	role: "bounded high-signal Neovim QoL plugin admission surface"

	constraints: [
		"GitHub issue body is the issue contract surface; repo-local CUE records the materialized slice",
		"Neovim QoL additions are editor-local projections or edit adapters",
		"xplr remains filesystem tree pane authority",
		"WezTerm remains project and session topology authority",
		"plugin supply is declared through config/pack.lua and vim.pack.add",
	]

	p0: [
		{
			id:        "which-key"
			plugin:    "https://github.com/folke/which-key.nvim"
			layer:     "ui"
			authority: "projection"
			admits: ["leader-key discovery", "desc-backed command graph", "low-recall keymap surface"]
			rejects: ["manual menu registry that drifts from keymaps", "opaque bindings without desc"]
		},
		{
			id:        "mini-surround"
			plugin:    "https://github.com/nvim-mini/mini.surround"
			layer:     "edit"
			authority: "adapter"
			admits: ["add/delete/replace surrounds", "dot-repeatable structural edits", "minimal setup"]
			rejects: ["snippet authority", "completion authority", "custom mapping churn before defaults fail"]
		},
		{
			id:        "mini-ai"
			plugin:    "https://github.com/nvim-mini/mini.ai"
			layer:     "edit"
			authority: "adapter"
			admits: ["stronger textobjects", "function/argument/tag object edits", "future CUE/Lua object extension"]
			rejects: ["full syntax-object framework", "treesitter-textobjects as first pass"]
		},
		{
			id:        "mini-pick"
			plugin:    "https://github.com/nvim-mini/mini.pick"
			layer:     "nav"
			authority: "projection"
			admits: ["files", "grep", "buffers", "help", "commands", "keymaps", "vim.ui.select"]
			rejects: ["project picker", "session picker", "persistent tree", "filesystem mutation adapter"]
		},
		{
			id:        "gitsigns"
			plugin:    "https://github.com/lewis6991/gitsigns.nvim"
			layer:     "git"
			authority: "projection"
			admits: ["hunk signs", "preview hunk", "stage/reset hunk", "next/previous hunk"]
			rejects: ["git porcelain replacement", "commit workflow ownership", "statusline dependency"]
		},
		{
			id:        "trouble"
			plugin:    "https://github.com/folke/trouble.nvim"
			layer:     "lang"
			authority: "projection"
			admits: ["workspace diagnostics", "buffer diagnostics", "quickfix", "loclist", "references", "symbols"]
			rejects: ["diagnostic source ownership", "inline diagnostic replacement"]
		},
	]

	p1: [
		{
			id:        "conform"
			plugin:    "https://github.com/stevearc/conform.nvim"
			layer:     "lang"
			authority: "adapter"
			gate:      "admit only when native formatter wrapper accumulates multi-filetype edge cases"
			admits: ["declared formatter registry", "manual format command", "opt-in format-on-save"]
			rejects: ["silent formatter fallback", "undeclared formatters", "hidden format-on-save before manual command"]
		},
		{
			id:        "nvim-lint"
			plugin:    "https://github.com/mfussenegger/nvim-lint"
			layer:     "lang"
			authority: "adapter"
			gate:      "admit only for external non-LSP linters projected through vim.diagnostic"
			admits: ["shellcheck", "actionlint", "markdownlint", "diagnostic projection"]
			rejects: ["duplicate LSP diagnostics", "lint-on-every-keystroke"]
		},
	]

	forbids: [
		"mini.files filesystem adapter",
		"oil.nvim filesystem adapter",
		"neo-tree or persistent Neovim file tree",
		"netrw replacement",
		"Neovim project picker",
		"Neovim workspace/session topology authority",
		"Neovim cwd/session persistence as project authority",
		"duplicate xplr tree-pane ownership inside Neovim",
		"LazyVim-style framework takeover",
		"Mason-managed language-tool authority",
		"generated artifacts as authority",
	]

	predicates: {
		"plugin-supply-native":       "plugin supply is declared in config/pack.lua through vim.pack.add"
		"layer-owned-modules":        "each admitted P0 plugin has a layer-owned Lua module"
		"desc-backed-discovery":      "which-key projects desc-backed keymaps rather than owning a second registry"
		"edit-adapter-only":          "mini.surround and mini.ai remain structural edit adapters only"
		"editor-local-picker":        "mini.pick does not select, rank, persist, or own project/session topology"
		"xplr-tree-authority":        "xplr remains the filesystem tree pane and focused path selection surface"
		"no-filesystem-tree-adapter": "mini.files, oil.nvim, neo-tree, and netrw replacement are not materialized"
		"diagnostic-projection-only": "trouble projects existing diagnostic/list surfaces without becoming diagnostic source authority"
		"git-projection-only":        "gitsigns does not replace git porcelain or commit workflow"
		"gated-p1-adapters":          "conform and nvim-lint remain gated P1 adapters until their admission predicates are satisfied"
	}
}

_negativeBottomChecks: {
	"mini-files-filesystem-adapter-rejected": "bottom"
	"oil-filesystem-adapter-rejected":        "bottom"
	"neotree-persistent-tree-rejected":       "bottom"
	"netrw-replacement-rejected":             "bottom"
	"neovim-project-picker-rejected":         "bottom"
	"workspace-session-topology-rejected":    "bottom"
	"which-key-parallel-registry-rejected":   "bottom"
	"diagnostic-source-takeover-rejected":    "bottom"
	"git-porcelain-takeover-rejected":        "bottom"
	"ungated-conform-rejected":               "bottom"
	"duplicate-lsp-lint-rejected":            "bottom"
}

dotfilesNvimQoLValidationPlan: {
	kind: "validation-plan"
	commands: [
		#CueExportExpectedSuccess & {
			expr: "dotfilesNvimQoLBlockSlice"
		},
	]
	assertions: {
		"no-filesystem-tree-adapter": {
			id:          "no-filesystem-tree-adapter"
			mode:        "forbids"
			family:      "assertion"
			description: "Rejected filesystem tree adapters remain outside the materialized Neovim QoL slice"
			expected:    dotfilesNvimQoLBlockSlice.forbids
			proof:       _negativeBottomChecks
			proofStatus: "proven"
		}
		"gated-p1-adapters": {
			id:          "gated-p1-adapters"
			mode:        "preserves"
			family:      "assertion"
			description: "Conform and nvim-lint remain declared as gated P1 adapters only"
			expected:    dotfilesNvimQoLBlockSlice.p1
			proof:       dotfilesNvimQoLBlockSlice.predicates."gated-p1-adapters"
			proofStatus: "proven"
		}
	}
}

dotfilesNvimQoLCompletionReport: {
	kind: "completion-report-contract"
	requiredSections: [
		"summary",
		"manifest workflow",
		"admitted QoL plugin set",
		"rejected filesystem tree adapters",
		"authority matrix",
		"target surfaces",
		"materialized config changes",
		"leader menu surface",
		"edit adapters",
		"picker and diagnostics projections",
		"git hunk projection",
		"gated formatter/linter adapters",
		"negative checks",
		"validation",
		"evidence",
		"forbidden attractors avoided",
	]
	expected: {
		state: "dotfiles-nvim-qol-block-slice"
		assertions: {
			"no-filesystem-tree-adapter": true
			"gated-p1-adapters":          true
		}
		fixtures: {
			for fixture, _ in _negativeBottomChecks {
				"\(fixture)": true
			}
		}
		subsumptions: {}
		commands: dotfilesNvimQoLValidationPlan.commands
		evidence: {
			"config-pack-lua":     true
			"layer-owned-modules": true
			"xplr-authority":      true
		}
	}
}
