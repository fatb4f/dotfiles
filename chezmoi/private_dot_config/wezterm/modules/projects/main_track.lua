return {
	id = "main-track",
	label = "main-track",
	workspace = "main-track",
	cwd = "~/src/main-track",

	env = {
		CONTRACT_ROOT = "~/src/main-track",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "export", cmd = "cue cmd export" },
		{ name = "shell", cmd = nil },
	},
}
