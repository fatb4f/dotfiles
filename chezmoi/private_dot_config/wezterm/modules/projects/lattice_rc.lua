return {
	id = "lattice_rc",
	label = "lattice_rc",
	workspace = "lattice_rc",
	cwd = "~/src/lattice_rc",

	env = {
		GIT_KATAS_ROOT = "~/src/lattice_rc",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "shell", cmd = nil },
	},
}
