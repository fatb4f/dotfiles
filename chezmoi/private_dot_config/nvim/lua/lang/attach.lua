-- lua/lang/attach.lua

local group = vim.api.nvim_create_augroup("native-lsp-attach", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = ev.buf,
				desc = desc,
			})
		end

		if client:supports_method("textDocument/hover") then
			map("n", "K", vim.lsp.buf.hover, "LSP hover")
		end

		if client:supports_method("textDocument/definition") then
			map("n", "gd", vim.lsp.buf.definition, "LSP goto definition")
		end

		if client:supports_method("textDocument/references") then
			map("n", "gr", vim.lsp.buf.references, "LSP references")
		end

		if client:supports_method("textDocument/rename") then
			map("n", "<leader>lr", vim.lsp.buf.rename, "LSP rename")
		end

		if client:supports_method("textDocument/formatting") then
			map({ "n", "x" }, "<leader>lf", function()
				vim.lsp.buf.format({ bufnr = ev.buf })
			end, "LSP format")
		end
	end,
})

vim.lsp.enable({
	"lua_ls",
	"cue",
	"bashls",
})
