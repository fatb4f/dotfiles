local M = {}

local clip_cache = { {}, "v" }

local function helper_env()
  local display = vim.env.DISPLAY
  if not display or display == "" then
    display = ":0"
  end

  local cmd = { "env", "DISPLAY=" .. display }
  if vim.env.XAUTHORITY and vim.env.XAUTHORITY ~= "" then
    table.insert(cmd, "XAUTHORITY=" .. vim.env.XAUTHORITY)
  end

  return cmd
end

local function has_cmd(cmd)
  return vim.fn.executable(cmd) == 1
end

local function run_xclip(args, input)
  if not has_cmd("xclip") then
    return false
  end

  local cmd = vim.list_extend(helper_env(), { "xclip" })
  vim.list_extend(cmd, args)
  vim.fn.system(cmd, input or "")
  return vim.v.shell_error == 0
end

local function run_wl_copy(input)
  if not has_cmd("wl-copy") then
    return false
  end

  vim.fn.system({ "wl-copy" }, input or "")
  return vim.v.shell_error == 0
end

local function run_wl_paste()
  if not has_cmd("wl-paste") then
    return nil
  end

  local result = vim.fn.systemlist({ "wl-paste", "--no-newline" })
  if vim.v.shell_error == 0 then
    return { result, "v" }
  end
end

local function provider()
  if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= "" then
    if has_cmd("wl-copy") and has_cmd("wl-paste") then
      return "wayland"
    end
  end

  if has_cmd("xclip") then
    return "xclip"
  end

  if has_cmd("wl-copy") and has_cmd("wl-paste") then
    return "wayland"
  end

  return nil
end

local function copy(lines, regtype)
  local text = table.concat(lines, "\n")
  clip_cache = { lines, regtype }

  if provider() == "wayland" and run_wl_copy(text) then
    return
  end

  if run_xclip({ "-in", "-selection", "clipboard" }, text) then
    return
  end

  vim.notify("Clipboard copy failed", vim.log.levels.WARN)
end

local function paste()
  local wayland_result = run_wl_paste()
  if wayland_result then
    return wayland_result
  end

  if has_cmd("xclip") then
    local cmd = vim.list_extend(helper_env(), { "xclip", "-out", "-selection", "clipboard" })
    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
      return { result, "v" }
    end
  end

  return clip_cache
end

function M.setup()
  vim.opt.clipboard = "unnamedplus"
  vim.g.loaded_clipboard_provider = nil

  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = false,
  }
end

return M
