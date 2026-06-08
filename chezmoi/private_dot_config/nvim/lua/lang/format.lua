-- lua/lang/format.lua

local group = vim.api.nvim_create_augroup("format-on-save", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype

    local lsp_formatters = {
      cue = true,
      typescript = true,
      typescriptreact = true,
      javascript = true,
      javascriptreact = true,
      json = true,
      jsonc = true,
    }

    if lsp_formatters[ft] then
      vim.lsp.buf.format({
        bufnr = ev.buf,
        timeout_ms = 2000,
      })
    end
  end,
})

-- lua/lang/format.lua continued

local function format_with(cmd, bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return
  end

  vim.system(cmd, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify(result.stderr, vim.log.levels.ERROR)
      end)
    end
  end)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.lua",
  callback = function(ev)
    format_with({ "stylua", vim.api.nvim_buf_get_name(ev.buf) }, ev.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = { "*.sh", "*.bash" },
  callback = function(ev)
    format_with({ "shfmt", "-w", vim.api.nvim_buf_get_name(ev.buf) }, ev.buf)
  end,
})
