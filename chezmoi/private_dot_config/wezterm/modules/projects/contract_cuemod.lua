return {
	id = "contract-cuemod",
	label = "contract.cuemod",
	workspace = "contract.cuemod",
	cwd = "~/src/contract.cuemod",

	env = {
		CONTRACT_ROOT = "~/src/contract.cuemod",
	},

	commands = {
		{ name = "edit", cmd = "nvim" },
		{ name = "export", cmd = "cue cmd export" },
		{ name = "shell", cmd = nil },
	},
}
