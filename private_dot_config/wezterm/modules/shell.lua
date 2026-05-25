local M = {}

function M.login_shell()
  return os.getenv("SHELL") or "zsh"
end

function M.login_args()
  return {
    M.login_shell(),
    "-l",
  }
end

function M.shell_cmd(cmd)
  return {
    M.login_shell(),
    "-lc",
    cmd,
  }
end

function M.login_shell_cmd()
  return string.format("%q", M.login_shell()) .. " -l"
end

function M.titled_cmd(title, cmd)
  return M.shell_cmd(
    "wezterm cli set-tab-title "
      .. string.format("%q", title)
      .. " >/dev/null 2>&1; exec "
      .. cmd
  )
end

return M
