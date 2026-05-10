return {
	{
		workspace = "name:web",
		persistent = true,
		default = true,
		layout = "master",
	},
	{
		workspace = "name:terminal",
		persistent = true,
		layout = "master",
		on_created_empty = "uwsm-app -- kitty",
	},
}
