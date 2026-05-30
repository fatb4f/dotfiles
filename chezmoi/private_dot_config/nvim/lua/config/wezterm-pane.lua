local M = {}

local defaults = {
  direction = "right",
  percent = 35,
  title = "WezTerm Pane",
  focus_backend = "smart-splits",
}

local config = vim.deepcopy(defaults)

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = config.title })
end

local function in_wezterm()
  return vim.env.WEZTERM_PANE ~= nil and vim.env.WEZTERM_PANE ~= ""
end

local function cache_key()
  return "wezterm_pane_id"
end

local function get_cached_pane()
  return vim.t[cache_key()]
end

local function set_cached_pane(pane_id)
  vim.t[cache_key()] = pane_id
end

local function clear_cached_pane()
  vim.t[cache_key()] = nil
end

local function run_cli(args, opts)
  opts = opts or {}

  if vim.fn.executable("wezterm") ~= 1 then
    return nil, "wezterm executable not found"
  end

  local argv = { "wezterm", "cli" }
  vim.list_extend(argv, args)

  local output = vim.fn.system(argv, opts.stdin)
  if vim.v.shell_error ~= 0 then
    return nil, vim.trim(output or "")
  end

  return vim.trim(output or ""), nil
end

local function direction_flag(direction)
  return ({
    right = "--right",
    left = "--left",
    up = "--top",
    down = "--bottom",
  })[direction]
end

local function smart_splits_move_fn(direction)
  return ({
    left = "move_cursor_left",
    down = "move_cursor_down",
    up = "move_cursor_up",
    right = "move_cursor_right",
  })[direction]
end

local function focus_pane(pane_id)
  local _, err = run_cli({ "activate-pane", "--pane-id", tostring(pane_id) })
  return err == nil, err
end

local function split_pane(opts)
  opts = opts or {}

  if not in_wezterm() then
    return nil, "WEZTERM_PANE is not set"
  end

  local direction = opts.direction or config.direction
  local flag = direction_flag(direction)

  if not flag then
    return nil, "invalid direction: " .. tostring(direction)
  end

  local output, err = run_cli({
    "split-pane",
    "--pane-id",
    vim.env.WEZTERM_PANE,
    flag,
    "--percent",
    tostring(opts.percent or config.percent),
    "--cwd",
    opts.cwd or vim.fn.getcwd(),
  })

  if err then
    return nil, err
  end

  if output == "" then
    return nil, "wezterm cli split-pane did not return a pane id"
  end

  set_cached_pane(output)
  return output, nil
end

local function ensure_pane(opts)
  local cached = get_cached_pane()

  if cached and cached ~= "" then
    local ok = focus_pane(cached)
    if ok then
      return cached, nil
    end

    clear_cached_pane()
  end

  return split_pane(opts)
end

local function focus_via_smart_splits(opts)
  opts = opts or {}

  local direction = opts.direction or config.direction
  local method = smart_splits_move_fn(direction)

  if not method then
    return nil, "invalid direction: " .. tostring(direction)
  end

  local ok, smart_splits = pcall(require, "smart-splits")
  if not ok then
    return nil, "smart-splits.nvim is required for WezTerm pane focus"
  end

  if type(smart_splits[method]) ~= "function" then
    return nil, "smart-splits missing method: " .. method
  end

  local focused_pane_id = nil
  local focus_err = nil

  smart_splits[method]({
    at_edge = function()
      focused_pane_id, focus_err = ensure_pane(opts)
    end,
  })

  if focus_err then
    return nil, focus_err
  end

  return focused_pane_id or true, nil
end

function M.toggle()
  local cached = get_cached_pane()

  if cached and cached ~= "" then
    local ok = focus_pane(cached)
    if ok then
      return cached
    end

    clear_cached_pane()
  end

  local pane_id, err = split_pane()
  if err then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  return pane_id
end

function M.focus(opts)
  if config.focus_backend ~= "smart-splits" then
    local pane_id, err = ensure_pane(opts)

    if err then
      notify(err, vim.log.levels.ERROR)
      return nil
    end

    return pane_id
  end

  local result, err = focus_via_smart_splits(opts)

  if err then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  return result
end

function M.run(command)
  if command == nil or vim.trim(command) == "" then
    notify("command is required", vim.log.levels.ERROR)
    return nil
  end

  local pane_id, err = ensure_pane()
  if err then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  local _, send_err = run_cli({
    "send-text",
    "--pane-id",
    pane_id,
    "--no-paste",
  }, { stdin = command .. "\n" })

  if send_err then
    notify(send_err, vim.log.levels.ERROR)
    return nil
  end

  return pane_id
end

function M.kill()
  local pane_id = get_cached_pane()

  if not pane_id or pane_id == "" then
    return
  end

  clear_cached_pane()

  local _, err = run_cli({
    "kill-pane",
    "--pane-id",
    pane_id,
  })

  if err then
    notify(err, vim.log.levels.ERROR)
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  vim.api.nvim_create_user_command("WeztermPaneToggle", function()
    M.toggle()
  end, {})

  vim.api.nvim_create_user_command("WeztermPaneFocus", function()
    M.focus()
  end, {})

  vim.api.nvim_create_user_command("WeztermPaneRun", function(command_opts)
    M.run(command_opts.args)
  end, {
    nargs = "+",
    complete = "shellcmd",
  })

  vim.api.nvim_create_user_command("WeztermPaneKill", function()
    M.kill()
  end, {})
end

return M
