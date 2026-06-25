-- lua/lang/completion.lua

vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.keymap.set({ "i", "s" }, "<tab>", function()
	if vim.snippet.active({ direction = 1 }) then
		return "<cmd>lua vim.snippet.jump(1)<cr>"
	end

	return "<tab>"
end, { expr = true, desc = "Snippet jump forward" })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
	if vim.snippet.active({ direction = -1 }) then
		return "<cmd>lua vim.snippet.jump(-1)<cr>"
	end

	return "<s-tab>"
end, { expr = true, desc = "Snippet jump backward" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("native-lsp-completion", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
			})
		end
	end,
})
