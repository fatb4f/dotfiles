---@type vim.lsp.Config
return {
	cmd = require("lang.process").bunx("bash-language-server", "start"),
	filetypes = { "sh", "bash" },
	root_markers = {
		".bashly.yml",
		".bashly.yaml",
		".git",
	},
}
