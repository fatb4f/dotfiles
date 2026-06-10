local xplr = xplr

local project_root = os.getenv("TERM_PROJECT_ROOT")

xplr.config.general.read_only = true
xplr.config.general.show_hidden = false
xplr.config.general.enable_mouse = false
xplr.config.general.hide_remaps_in_help_menu = true

xplr.config.general.table.header.cols = {
	{ format = " project tree" },
}
xplr.config.general.table.row.cols = {
	{ format = "builtin.fmt_general_table_row_cols_1" },
}
xplr.config.general.table.col_widths = {
	{ Percentage = 100 },
}

xplr.config.modes.builtin.default.key_bindings.on_key["enter"] = {
	help = "open",
	messages = {
		{
			BashExecSilently0 = [===[
        if [ -d "${XPLR_FOCUS_PATH:?}" ]; then
          "$XPLR" -m Enter
        elif nvim --server "${TERM_NVIM_SOCKET:?}" --remote "${XPLR_FOCUS_PATH:?}"; then
          "$XPLR" -m 'LogSuccess: %q' "opened ${XPLR_FOCUS_PATH}"
        else
          "$XPLR" -m 'LogError: %q' "Neovim session unavailable: ${TERM_NVIM_SOCKET:-unset}"
        fi
      ]===],
		},
	},
}

xplr.config.modes.builtin.default.key_bindings.on_key["right"] =
	xplr.config.modes.builtin.default.key_bindings.on_key["enter"]

local on_load = {}
if project_root and project_root:sub(1, 1) == "/" then
	table.insert(on_load, { SetVroot = project_root })
	table.insert(on_load, { ChangeDirectory = project_root })
end

return {
	on_load = on_load,
}
