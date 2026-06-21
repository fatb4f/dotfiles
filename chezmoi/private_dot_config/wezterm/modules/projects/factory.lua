return {
	id = "factory",
	label = "factory",
	workspace = "factory",
	cwd = "~/src/factory",
	env = {
		FACTORY_ROOT = "~/src/factory",
	},
	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "check", cmd = "just check" },
		{ name = "shell", cmd = nil },
	},
}
