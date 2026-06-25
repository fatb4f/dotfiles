---@type vim.lsp.Config
return {
	cmd = require("lang.process").bun_run("cue:lsp"),
	filetypes = { "cue" },
	root_markers = {
		"cue.mod",
		".git",
	},
}
