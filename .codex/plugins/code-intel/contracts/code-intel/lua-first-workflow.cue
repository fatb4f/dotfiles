package codeintel

#NonEmptyString: string & !=""
#ContainedPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#Provider: close({
	id: #NonEmptyString
	kind: "mcp" | "lsp" | "types" | "workflow"
	paths: [...#ContainedPath] & [_, ...]
	authority: false
	evidenceOnly: true
})

#LuaEntrypoint: close({
	id: #NonEmptyString
	language: "lua"
	path: #ContainedPath
	domain: "nvim" | "wezterm" | "dotfiles"
	provider: "lua-language-server"
	typeOverlays: [...#NonEmptyString]
	authority: "dotfiles-source"
})

#LuaFirstStep: close({
	order: int & >0
	id: #NonEmptyString
	goal: #NonEmptyString
	authority: "dotfiles-source" | "evidence-only"
})

#CodeIntelLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.v1"
	id: #NonEmptyString
	intent: #NonEmptyString
	entrypoints: [...#LuaEntrypoint] & [_, ...]
	providers: [...#Provider] & [_, ...]
	steps: [...#LuaFirstStep] & [_, ...]
	authority: close({
		owns: [...#NonEmptyString] & [_, ...]
		doesNotOwn: [...#NonEmptyString] & [_, ...]
	})
})

codeIntelLuaFirstWorkflow: #CodeIntelLuaFirstWorkflow & {
	id: "dotfiles-code-intel-lua-first"
	intent: "Resolve dotfiles Lua surfaces before generic repository context."
	entrypoints: [
		{id: "nvim-init", language: "lua", path: ".config/nvim/init.lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "nvim-lua-modules", language: "lua", path: ".config/nvim/lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "wezterm-config", language: "lua", path: ".config/wezterm/wezterm.lua", domain: "wezterm", provider: "lua-language-server", typeOverlays: ["wezterm-types"], authority: "dotfiles-source"},
	]
	providers: [
		{id: "mcp-tool-registry", kind: "mcp", paths: ["generated/mcp/tool-registry.json"], authority: false, evidenceOnly: true},
		{id: "mcp-context-projection", kind: "mcp", paths: ["generated/mcp/context-projection.json"], authority: false, evidenceOnly: true},
		{id: "cue-lsp", kind: "lsp", paths: ["generated/lsp/cue-lsp.json"], authority: false, evidenceOnly: true},
		{id: "lua-language-server", kind: "lsp", paths: ["generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"], authority: false, evidenceOnly: true},
		{id: "wezterm-types", kind: "types", paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"], authority: false, evidenceOnly: true},
		{id: "nvim-vim-types", kind: "types", paths: ["generated/types/nvim/vim.lua"], authority: false, evidenceOnly: true},
	]
	steps: [
		{order: 1, id: "collect-lua-entrypoints", goal: "Resolve Lua entrypoints before generic dotfiles paths.", authority: "dotfiles-source"},
		{order: 2, id: "load-type-overlays", goal: "Attach Neovim and WezTerm type overlays as read-only evidence.", authority: "evidence-only"},
		{order: 3, id: "route-provider", goal: "Select lua-language-server or cue-lsp by path and language.", authority: "evidence-only"},
		{order: 4, id: "project-diagnostics", goal: "Project diagnostics as evidence, not mutation authority.", authority: "evidence-only"},
	]
	authority: {
		owns: ["code-intel bundle workflow shape", "provider ordering for Lua-first dotfiles work"]
		doesNotOwn: ["fatb4f/dotfiles source authority", "runtime execution", "truth of LSP diagnostics", "WezTerm runtime behavior", "Neovim runtime behavior"]
	}
}
