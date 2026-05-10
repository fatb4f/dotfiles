hl.on("hyprland.start", function()
  -- Keep this minimal.
  -- UWSM/systemd-user should own session companions.
end)

hl.on("config.reloaded", function()
  -- Optional debug hook.
end)
