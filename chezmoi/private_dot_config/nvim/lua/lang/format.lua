-- lua/lang/format.lua

local group = vim.api.nvim_create_augroup("format-on-save", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype

    local lsp_formatters = {
      cue = true,
    }

    if lsp_formatters[ft] then
      vim.lsp.buf.format({
        bufnr = ev.buf,
        timeout_ms = 2000,
      })
    end
  end,
})

local function format_with(cmd, bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(lines, "\n")
  if vim.bo[bufnr].endofline then
    input = input .. "\n"
  end

  local result = vim.system(cmd, {
    stdin = input,
    text = true,
  }):wait()

  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  local formatted = vim.split(result.stdout, "\n", { plain = true })
  if formatted[#formatted] == "" then
    table.remove(formatted)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.lua",
  callback = function(ev)
    format_with({
      "stylua",
      "--stdin-filepath",
      vim.api.nvim_buf_get_name(ev.buf),
      "-",
    }, ev.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = { "*.sh", "*.bash" },
  callback = function(ev)
    format_with({ "shfmt" }, ev.buf)
  end,
})
