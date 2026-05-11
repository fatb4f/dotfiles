local home = os.getenv("HOME")
local menu = home .. "/.local/bin/app-launcher"

-- launch
hl.bind("SUPER + Return", hl.dsp.exec_cmd("uwsm-app -- kitty"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("uwsm-app -- chromium"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd(menu))

-- window state
hl.bind("SUPER + Q", hl.dsp.window.close())

-- master layout current workspace
hl.bind("SUPER + Tab", hl.dsp.layout("swapnext loop"))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.layout("swapprev loop"))

-- focus monitor
hl.bind("SUPER + H", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ monitor = "r" }))

-- move focused workspace to monitor
hl.bind("SUPER + CTRL + H", hl.dsp.workspace.move({ monitor = "eDP-1", follow = true }))
hl.bind("SUPER + CTRL + L", hl.dsp.workspace.move({ monitor = "HDMI-A-1", follow = true }))

-- explicit move focused window to named monitor
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ monitor = "eDP-1", follow = true }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ monitor = "HDMI-A-1", follow = true }))

-- mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
