local M = {}

local function kitty_target()
  if vim.env.KITTY_LISTEN_ON and vim.env.KITTY_LISTEN_ON ~= "" then
    return vim.env.KITTY_LISTEN_ON
  end

  if vim.fn.filereadable("/tmp/kitty") == 1 then
    return "unix:/tmp/kitty"
  end
end

function M.overlay_shell(opts)
  local target = kitty_target()
  if not target then
    vim.notify("Kitty remote control is not available", vim.log.levels.WARN)
    return
  end

  opts = opts or {}

  local cwd = opts.cwd or vim.fn.getcwd()
  local shell = opts.shell or vim.env.SHELL or "/bin/bash"

  vim.system({
    "kitty",
    "@",
    "--to",
    target,
    "launch",
    "--type=overlay-main",
    "--cwd",
    cwd,
    shell,
    "-l",
  }, { detach = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify(
          ("Failed to open Kitty overlay shell (exit %d)"):format(result.code),
          vim.log.levels.ERROR
        )
      end)
    end
  end)
end

return M
