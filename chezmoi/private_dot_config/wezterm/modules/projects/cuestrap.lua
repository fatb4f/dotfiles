return {
	id = "cuestrap",
	label = "cuestrap",
	workspace = "cuestrap",
	cwd = "~/src/cuestrap",

	env = {
		GIT_KATAS_ROOT = "~/src/cuestrap",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "shell", cmd = nil },
	},
}
