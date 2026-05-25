local M = {}

function M.sync_lualine_base16_globals()
  local ok, tinted = pcall(require, "tinted-nvim")
  if not ok then
    return
  end

  local palette = tinted.get_palette()
  if not palette then
    return
  end

  for i = 0, 15 do
    local suffix = string.format("%02X", i)
    local value = palette["base" .. suffix]
    if value then
      vim.g["base16_gui" .. suffix] = value
      vim.g["tinted_gui" .. suffix] = value
    end
  end
end

return M
