-- Reactive Hyprland workspace seed.
--
-- Contract:
--   Hyprland owns windows, focus, and role placement.
--   Terminals/file managers are replaceable role clients.
--   Neovim is addressed through the editor role adapter.

local function exec_role(command)
	hl.dsp.exec_cmd(command)()
end

-- Role binds.  These call the userland role adapter rather than launching
-- terminal/file-manager/editor commands directly from Hyprland config.
hl.bind("SUPER + E", function()
	exec_role("editor-open")
end)

hl.bind("SUPER + F", function()
	exec_role("ide-role files")
end)

hl.bind("SUPER + T", function()
	exec_role("ide-role tests")
end)

hl.bind("SUPER + D", function()
	exec_role("ide-role debug")
end)

hl.bind("SUPER + R", function()
	exec_role("ide-role repl")
end)

hl.bind("SUPER + G", function()
	exec_role("ide-role logs")
end)

-- Current-window utility binds for early iteration.
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Role placement seed.  Keep this conservative until the role reconciler and
-- custom layout are stable; the role scripts own open/focus for now.
for _, role_name in ipairs({ "editor", "files", "tests", "debug", "repl", "logs" }) do
	hl.window_rule({
		name = "hyprwm-" .. role_name .. "-workspace",
		match = { class = "hyprwm-" .. role_name },
		workspace = "name:ide",
	})
end
