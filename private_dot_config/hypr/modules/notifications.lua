-- ~/.config/hypr/modules/notifications.lua

-- Lucent is D-Bus activated.
-- Hyprland only owns visual layer policy.

hl.config({
	decoration = {
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			ignore_opacity = false,
		},
	},
})

hl.layer_rule({
	name = "lucent-notification-blur",
	match = {
		namespace = "lucent-notification",
	},
	blur = true,
	ignore_alpha = 0.15,
})
