return {
	mod = "SUPER",

	commands = {
		terminal = "uwsm-app -- kitty",
		menu = os.getenv("HOME") .. "/.local/bin/app-launcher",
		browser = "uwsm-app -- chromium",
	},

	layout = {
		default = "master",
	},
}
