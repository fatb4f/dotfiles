return {
	id = "dotfiles",
	label = "dotfiles",
	workspace = "dotfiles",
	cwd = "~/src/dotfiles",

	env = {
		DOTFILES_ROOT = "~/src/dotfiles",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "mcp", cmd = { "term-git-mcp" } },
		{ name = "shell", cmd = nil },
	},
}
