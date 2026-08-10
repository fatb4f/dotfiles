hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE")
	hl.exec_cmd("hyprshade auto")
end)
