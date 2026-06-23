return {
	id = "semagrams",
	label = "semagrams",
	workspace = "semagrams",
	cwd = "~/src/semagrams",
	root = "~/src/semagrams",

	env = {
		FACTORY_ROOT = "~/src/semagrams",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "check", cmd = "just check" },
		{ name = "shell", cmd = nil },
	},
}
