local wezterm = require("wezterm")

return {
	id = wezterm.home_dir,
	label = "~",
	workspace = wezterm.home_dir,
	cwd = wezterm.home_dir,

	env = {},

	commands = {
		{ name = "shell", cmd = nil },
	},
}
