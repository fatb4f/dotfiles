return {
	windows = {
		{
			name = "terminal-workspace",
			match = { class = "kitty" },
			workspace = "name:terminal",
		},
		{
			name = "wezterm-terminal-workspace",
			match = { class = "org.wezfurlong.wezterm" },
			workspace = "name:terminal",
		},
		{
			name = "browser-workspace",
			match = { class = "chromium" },
			workspace = "name:web",
		},
	},

	layers = {},
}
