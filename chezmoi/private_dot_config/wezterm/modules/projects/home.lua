local wezterm = require("wezterm")

return {
	id = "home",
	label = "~",
	workspace = wezterm.home_dir,
	cwd = wezterm.home_dir,

	env = {},
}
