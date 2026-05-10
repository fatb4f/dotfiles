return {
	{
		workspace = "name:web",
		persistent = true,
		default = true,
		layout = "master",
		on_created_empty = "browser",
	},
	{
		workspace = "name:terminal",
		persistent = true,
		layout = "master",
		on_created_empty = "terminal",
	},
}
