return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = function()
			local codex_acp = vim.fn.exepath("codex-acp")

			return {
				interactions = {
					chat = {
						adapter = "codex",
					},
				},
				adapters = {
					acp = {
						codex = function()
							return require("codecompanion.adapters").extend("codex", {
								commands = {
									default = { codex_acp ~= "" and codex_acp or "codex-acp" },
								},
								defaults = {
									auth_method = "chatgpt",
								},
							})
						end,
					},
				},
			}
		end,
	},
}
