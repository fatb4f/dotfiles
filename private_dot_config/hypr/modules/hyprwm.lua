-- Reactive Hyprland workspace seed.
--
-- Contract:
--   Hyprland owns windows, focus, and role placement.
--   Terminals/file managers are replaceable role clients.
--   Neovim is addressed through IDE_NVIM by nvim-open-here.

local function role(name)
	hl.dsp.exec_cmd("ide-role " .. name)()
end

-- Role binds.  These call the userland role adapter rather than launching
-- terminal/file-manager/editor commands directly from Hyprland config.
hl.bind("SUPER + E", function()
	role("editor")
end)

hl.bind("SUPER + F", function()
	role("files")
end)

hl.bind("SUPER + T", function()
	role("tests")
end)

hl.bind("SUPER + D", function()
	role("debug")
end)

hl.bind("SUPER + R", function()
	role("repl")
end)

hl.bind("SUPER + G", function()
	role("logs")
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
