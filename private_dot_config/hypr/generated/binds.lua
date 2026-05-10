return {
	-- launch / session
	{ chord = "SUPER + Return", action = "dsp", dispatcher = "exec_cmd", command = "terminal" },
	{ chord = "SUPER + Space", action = "dsp", dispatcher = "exec_cmd", command = "menu" },
	{ chord = "SUPER + SHIFT + E", action = "dsp", dispatcher = "exec_cmd", command = "uwsm_stop" },

	-- window state
	{ chord = "SUPER + Q", action = "dsp", dispatcher = "window.close" },
	{
		chord = "SUPER + F",
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
		chord = "SUPER + V",
		action = "dsp",
		dispatcher = "window.float",
		args = {
			{ action = "toggle" },
		},
	},

	-- focus windows: niri-like HJKL
	{ chord = "SUPER + H", action = "dsp", dispatcher = "focus", args = { { direction = "l" } } },
	{ chord = "SUPER + J", action = "dsp", dispatcher = "focus", args = { { direction = "d" } } },
	{ chord = "SUPER + K", action = "dsp", dispatcher = "focus", args = { { direction = "u" } } },
	{ chord = "SUPER + L", action = "dsp", dispatcher = "focus", args = { { direction = "r" } } },

	-- move windows
	{ chord = "SUPER + CTRL + H", action = "dsp", dispatcher = "window.move", args = { { direction = "l" } } },
	{ chord = "SUPER + CTRL + J", action = "dsp", dispatcher = "window.move", args = { { direction = "d" } } },
	{ chord = "SUPER + CTRL + K", action = "dsp", dispatcher = "window.move", args = { { direction = "u" } } },
	{ chord = "SUPER + CTRL + L", action = "dsp", dispatcher = "window.move", args = { { direction = "r" } } },

	-- workspaces
	{ chord = "SUPER + 1", action = "dsp", dispatcher = "focus", args = { { workspace = "1" } } },
	{ chord = "SUPER + 2", action = "dsp", dispatcher = "focus", args = { { workspace = "2" } } },
	{ chord = "SUPER + 3", action = "dsp", dispatcher = "focus", args = { { workspace = "3" } } },
	{ chord = "SUPER + 4", action = "dsp", dispatcher = "focus", args = { { workspace = "4" } } },
	{ chord = "SUPER + 5", action = "dsp", dispatcher = "focus", args = { { workspace = "5" } } },
	{ chord = "SUPER + 6", action = "dsp", dispatcher = "focus", args = { { workspace = "6" } } },
	{ chord = "SUPER + 7", action = "dsp", dispatcher = "focus", args = { { workspace = "7" } } },
	{ chord = "SUPER + 8", action = "dsp", dispatcher = "focus", args = { { workspace = "8" } } },
	{ chord = "SUPER + 9", action = "dsp", dispatcher = "focus", args = { { workspace = "9" } } },

	-- relative workspace focus
	{ chord = "SUPER + U", action = "dsp", dispatcher = "focus", args = { { workspace = "r-1" } } },
	{ chord = "SUPER + I", action = "dsp", dispatcher = "focus", args = { { workspace = "r+1" } } },

	-- move window to workspace
	{ chord = "SUPER + CTRL + 1", action = "dsp", dispatcher = "window.move", args = { { workspace = "1" } } },
	{ chord = "SUPER + CTRL + 2", action = "dsp", dispatcher = "window.move", args = { { workspace = "2" } } },
	{ chord = "SUPER + CTRL + 3", action = "dsp", dispatcher = "window.move", args = { { workspace = "3" } } },
	{ chord = "SUPER + CTRL + 4", action = "dsp", dispatcher = "window.move", args = { { workspace = "4" } } },
	{ chord = "SUPER + CTRL + 5", action = "dsp", dispatcher = "window.move", args = { { workspace = "5" } } },
	{ chord = "SUPER + CTRL + 6", action = "dsp", dispatcher = "window.move", args = { { workspace = "6" } } },
	{ chord = "SUPER + CTRL + 7", action = "dsp", dispatcher = "window.move", args = { { workspace = "7" } } },
	{ chord = "SUPER + CTRL + 8", action = "dsp", dispatcher = "window.move", args = { { workspace = "8" } } },
	{ chord = "SUPER + CTRL + 9", action = "dsp", dispatcher = "window.move", args = { { workspace = "9" } } },

	-- move window to relative workspace
	{ chord = "SUPER + CTRL + U", action = "dsp", dispatcher = "window.move", args = { { workspace = "r-1" } } },
	{ chord = "SUPER + CTRL + I", action = "dsp", dispatcher = "window.move", args = { { workspace = "r+1" } } },

	-- monitor focus
	{ chord = "SUPER + SHIFT + H", action = "dsp", dispatcher = "focus", args = { { monitor = "l" } } },
	{ chord = "SUPER + SHIFT + J", action = "dsp", dispatcher = "focus", args = { { monitor = "d" } } },
	{ chord = "SUPER + SHIFT + K", action = "dsp", dispatcher = "focus", args = { { monitor = "u" } } },
	{ chord = "SUPER + SHIFT + L", action = "dsp", dispatcher = "focus", args = { { monitor = "r" } } },

	-- move window to monitor
	{ chord = "SUPER + SHIFT + CTRL + H", action = "dsp", dispatcher = "window.move", args = { { monitor = "l" } } },
	{ chord = "SUPER + SHIFT + CTRL + J", action = "dsp", dispatcher = "window.move", args = { { monitor = "d" } } },
	{ chord = "SUPER + SHIFT + CTRL + K", action = "dsp", dispatcher = "window.move", args = { { monitor = "u" } } },
	{ chord = "SUPER + SHIFT + CTRL + L", action = "dsp", dispatcher = "window.move", args = { { monitor = "r" } } },

	-- master/layout
	{ chord = "SUPER + M", action = "dsp", dispatcher = "layout", args = { "swapwithmaster master" } },
	{ chord = "SUPER + Tab", action = "dsp", dispatcher = "layout", args = { "cyclenext" } },
	{ chord = "SUPER + SHIFT + Tab", action = "dsp", dispatcher = "layout", args = { "cycleprev" } },
	{ chord = "SUPER + Equal", action = "dsp", dispatcher = "layout", args = { "mfact +0.05" } },
	{ chord = "SUPER + Minus", action = "dsp", dispatcher = "layout", args = { "mfact -0.05" } },

	-- mouse
	{ chord = "SUPER + mouse:272", action = "dsp", dispatcher = "window.drag", flags = { mouse = true } },
	{ chord = "SUPER + mouse:273", action = "dsp", dispatcher = "window.resize", flags = { mouse = true } },
}
