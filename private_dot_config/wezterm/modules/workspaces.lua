local wezterm = require("wezterm")
local mux = wezterm.mux

local shell = require("modules.shell")
local projects = require("modules.projects")

local M = {}

local function workspace_exists(name)
  for _, ws in ipairs(mux.get_workspace_names()) do
    if ws == name then
      return true
    end
  end

  return false
end

local function spawn_project_workspace(name, project)
  local _, _, window = mux.spawn_window({
    workspace = project.workspace,
    cwd = project.root,
    args = shell.titled_cmd(name .. ":edit", "nvim ."),
  })

  window:spawn_tab({
    cwd = project.root,
    args = shell.titled_cmd(name .. ":shell", shell.login_shell_cmd()),
  })

  window:spawn_tab({
    cwd = project.root,
    args = shell.titled_cmd(name .. ":task", shell.login_shell_cmd()),
  })

  mux.set_active_workspace(project.workspace)
end

local function switch_or_spawn(name)
  local project = projects[name]
  if not project then
    wezterm.log_warn("unknown project workspace: " .. tostring(name))
    return
  end

  if workspace_exists(project.workspace) then
    mux.set_active_workspace(project.workspace)
  else
    spawn_project_workspace(name, project)
  end
end

function M.apply_to_config(config)
  config.keys = config.keys or {}

  table.insert(config.keys, {
    key = "1",
    mods = "ALT",
    action = wezterm.action_callback(function()
      switch_or_spawn("dots")
    end),
  })

  table.insert(config.keys, {
    key = "3",
    mods = "ALT",
    action = wezterm.action_callback(function()
      switch_or_spawn("home")
    end),
  })

  table.insert(config.keys, {
    key = "9",
    mods = "ALT",
    action = wezterm.action.ShowLauncherArgs({
      flags = "FUZZY|WORKSPACES",
    }),
  })
end

return M
