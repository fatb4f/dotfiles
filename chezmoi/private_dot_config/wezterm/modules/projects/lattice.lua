return {
	id = "lattice",
	label = "lattice",
	workspace = "lattice",
	cwd = "~/src/lattice",

	env = {
		GIT_KATAS_ROOT = "~/src/lattice",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "shell", cmd = nil },
	},
}
