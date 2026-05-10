return {
	-- launch
	{ chord = "$mod + Return", action = "dsp", dispatcher = "exec_cmd", command = "terminal" },
	{ chord = "$mod + Space", action = "dsp", dispatcher = "exec_cmd", command = "menu" },

	-- window state
	{ chord = "$mod + Q", action = "dsp", dispatcher = "window.close" },
	{
		chord = "$mod + F",
		action = "dsp",
		dispatcher = "window.fullscreen",
		args = {
			{
				mode = "maximized",
				action = "toggle",
			},
		},
	},
	{
		chord = "$mod + V",
		action = "dsp",
		dispatcher = "window.float",
		args = {
			{
				action = "toggle",
			},
		},
	},

	-- focus windows: niri-like HJKL
	{ chord = "$mod + H", action = "dsp", dispatcher = "focus", args = { { direction = "l" } } },
	{ chord = "$mod + J", action = "dsp", dispatcher = "focus", args = { { direction = "d" } } },
	{ chord = "$mod + K", action = "dsp", dispatcher = "focus", args = { { direction = "u" } } },
	{ chord = "$mod + L", action = "dsp", dispatcher = "focus", args = { { direction = "r" } } },

	-- move windows
	{ chord = "$mod + CTRL + H", action = "dsp", dispatcher = "window.move", args = { { direction = "l" } } },
	{ chord = "$mod + CTRL + J", action = "dsp", dispatcher = "window.move", args = { { direction = "d" } } },
	{ chord = "$mod + CTRL + K", action = "dsp", dispatcher = "window.move", args = { { direction = "u" } } },
	{ chord = "$mod + CTRL + L", action = "dsp", dispatcher = "window.move", args = { { direction = "r" } } },

	-- workspace focus
	{ chord = "$mod + 1", action = "dsp", dispatcher = "focus", args = { { workspace = "1" } } },
	{ chord = "$mod + 2", action = "dsp", dispatcher = "focus", args = { { workspace = "2" } } },
	{ chord = "$mod + 3", action = "dsp", dispatcher = "focus", args = { { workspace = "3" } } },
	{ chord = "$mod + 4", action = "dsp", dispatcher = "focus", args = { { workspace = "4" } } },
	{ chord = "$mod + 5", action = "dsp", dispatcher = "focus", args = { { workspace = "5" } } },
	{ chord = "$mod + 6", action = "dsp", dispatcher = "focus", args = { { workspace = "6" } } },
	{ chord = "$mod + 7", action = "dsp", dispatcher = "focus", args = { { workspace = "7" } } },
	{ chord = "$mod + 8", action = "dsp", dispatcher = "focus", args = { { workspace = "8" } } },
	{ chord = "$mod + 9", action = "dsp", dispatcher = "focus", args = { { workspace = "9" } } },

	-- relative workspace focus
	{ chord = "$mod + U", action = "dsp", dispatcher = "focus", args = { { workspace = "r-1" } } },
	{ chord = "$mod + I", action = "dsp", dispatcher = "focus", args = { { workspace = "r+1" } } },

	-- move window to workspace
	{ chord = "$mod + CTRL + 1", action = "dsp", dispatcher = "window.move", args = { { workspace = "1" } } },
	{ chord = "$mod + CTRL + 2", action = "dsp", dispatcher = "window.move", args = { { workspace = "2" } } },
	{ chord = "$mod + CTRL + 3", action = "dsp", dispatcher = "window.move", args = { { workspace = "3" } } },
	{ chord = "$mod + CTRL + 4", action = "dsp", dispatcher = "window.move", args = { { workspace = "4" } } },
	{ chord = "$mod + CTRL + 5", action = "dsp", dispatcher = "window.move", args = { { workspace = "5" } } },
	{ chord = "$mod + CTRL + 6", action = "dsp", dispatcher = "window.move", args = { { workspace = "6" } } },
	{ chord = "$mod + CTRL + 7", action = "dsp", dispatcher = "window.move", args = { { workspace = "7" } } },
	{ chord = "$mod + CTRL + 8", action = "dsp", dispatcher = "window.move", args = { { workspace = "8" } } },
	{ chord = "$mod + CTRL + 9", action = "dsp", dispatcher = "window.move", args = { { workspace = "9" } } },

	-- monitor focus
	{ chord = "$mod + SHIFT + H", action = "dsp", dispatcher = "focus", args = { { monitor = "l" } } },
	{ chord = "$mod + SHIFT + J", action = "dsp", dispatcher = "focus", args = { { monitor = "d" } } },
	{ chord = "$mod + SHIFT + K", action = "dsp", dispatcher = "focus", args = { { monitor = "u" } } },
	{ chord = "$mod + SHIFT + L", action = "dsp", dispatcher = "focus", args = { { monitor = "r" } } },

	-- move window to monitor
	{ chord = "$mod + SHIFT + CTRL + H", action = "dsp", dispatcher = "window.move", args = { { monitor = "l" } } },
	{ chord = "$mod + SHIFT + CTRL + J", action = "dsp", dispatcher = "window.move", args = { { monitor = "d" } } },
	{ chord = "$mod + SHIFT + CTRL + K", action = "dsp", dispatcher = "window.move", args = { { monitor = "u" } } },
	{ chord = "$mod + SHIFT + CTRL + L", action = "dsp", dispatcher = "window.move", args = { { monitor = "r" } } },

	-- master/layout
	{ chord = "$mod + M", action = "dsp", dispatcher = "layout", args = { "swapwithmaster master" } },
	{ chord = "$mod + Tab", action = "dsp", dispatcher = "layout", args = { "cyclenext" } },
	{ chord = "$mod + SHIFT + Tab", action = "dsp", dispatcher = "layout", args = { "cycleprev" } },
	{ chord = "$mod + Equal", action = "dsp", dispatcher = "layout", args = { "mfact +0.05" } },
	{ chord = "$mod + Minus", action = "dsp", dispatcher = "layout", args = { "mfact -0.05" } },

	-- mouse
	{ chord = "$mod + mouse:272", action = "dsp", dispatcher = "window.drag", flags = { mouse = true } },
	{ chord = "$mod + mouse:273", action = "dsp", dispatcher = "window.resize", flags = { mouse = true } },
}
