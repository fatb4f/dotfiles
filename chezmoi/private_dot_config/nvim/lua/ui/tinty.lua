-- lua/ui/tinty.lua

local M = {}

local function first_readable(paths)
	for _, path in ipairs(paths) do
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
end

local function load_palette(path)
	local ok, palette = pcall(dofile, path)
	if ok and type(palette) == "table" then
		return palette
	end
end

local function from_base16(palette)
	if not palette.base00 or not palette.base05 then
		return nil
	end

	return {
		bg = palette.base00,
		bg_alt = palette.base01 or palette.base00,
		bg_highlight = palette.base02 or palette.base01 or palette.base00,
		fg_muted = palette.base03 or palette.base05,
		fg_subtle = palette.base04 or palette.base05,
		fg = palette.base05,
		fg_bright = palette.base06 or palette.base05,
		red = palette.base08 or palette.base05,
		orange = palette.base09 or palette.base08 or palette.base05,
		yellow = palette.base0A or palette.base09 or palette.base05,
		green = palette.base0B or palette.base05,
		cyan = palette.base0C or palette.base0D or palette.base05,
		blue = palette.base0D or palette.base05,
		purple = palette.base0E or palette.base0D or palette.base05,
	}
end

local function from_wezterm(palette)
	if not palette.background or not palette.foreground then
		return nil
	end

	local ansi = palette.ansi or {}
	local brights = palette.brights or {}

	return {
		bg = palette.background,
		bg_alt = palette.selection_bg or brights[1] or ansi[1] or palette.background,
		bg_highlight = brights[1] or palette.selection_bg or ansi[1] or palette.background,
		fg_muted = brights[1] or ansi[8] or palette.foreground,
		fg_subtle = ansi[8] or brights[1] or palette.foreground,
		fg = palette.foreground,
		fg_bright = brights[8] or palette.foreground,
		red = ansi[2] or brights[2] or palette.foreground,
		yellow = ansi[4] or brights[4] or palette.foreground,
		green = ansi[3] or brights[3] or palette.foreground,
		cyan = ansi[7] or brights[7] or ansi[6] or palette.foreground,
		blue = ansi[5] or brights[5] or palette.foreground,
		purple = ansi[6] or brights[6] or palette.foreground,
	}
end

local function normalize(palette)
	return from_base16(palette) or from_wezterm(palette)
end

local function apply(colors)
	vim.o.termguicolors = true
	vim.g.colors_name = "tinty"

	local set = vim.api.nvim_set_hl

	set(0, "Normal", { fg = colors.fg, bg = colors.bg })
	set(0, "NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
	set(0, "FloatBorder", { fg = colors.fg_subtle, bg = colors.bg_alt })
	set(0, "Visual", { bg = colors.bg_highlight })
	set(0, "Search", { fg = colors.bg, bg = colors.yellow })
	set(0, "IncSearch", { fg = colors.bg, bg = colors.orange or colors.yellow })
	set(0, "CurSearch", { fg = colors.bg, bg = colors.orange or colors.yellow })
	set(0, "Cursor", { fg = colors.bg, bg = colors.fg })
	set(0, "CursorLine", { bg = colors.bg_alt })
	set(0, "CursorLineNr", { fg = colors.yellow, bg = colors.bg_alt, bold = true })
	set(0, "LineNr", { fg = colors.fg_muted })
	set(0, "SignColumn", { fg = colors.fg_subtle, bg = colors.bg })
	set(0, "ColorColumn", { bg = colors.bg_alt })
	set(0, "WinSeparator", { fg = colors.bg_highlight })
	set(0, "StatusLine", { fg = colors.fg, bg = colors.bg_highlight })
	set(0, "StatusLineNC", { fg = colors.fg_subtle, bg = colors.bg_alt })
	set(0, "Pmenu", { fg = colors.fg, bg = colors.bg_alt })
	set(0, "PmenuSel", { fg = colors.bg, bg = colors.blue })
	set(0, "PmenuThumb", { bg = colors.fg_muted })
	set(0, "TabLine", { fg = colors.fg_subtle, bg = colors.bg_alt })
	set(0, "TabLineSel", { fg = colors.fg_bright, bg = colors.bg })
	set(0, "TabLineFill", { bg = colors.bg_alt })

	set(0, "Comment", { fg = colors.fg_muted, italic = true })
	set(0, "Constant", { fg = colors.cyan })
	set(0, "String", { fg = colors.green })
	set(0, "Identifier", { fg = colors.blue })
	set(0, "Statement", { fg = colors.purple })
	set(0, "PreProc", { fg = colors.yellow })
	set(0, "Type", { fg = colors.cyan })
	set(0, "Special", { fg = colors.orange or colors.yellow })

	set(0, "DiagnosticError", { fg = colors.red })
	set(0, "DiagnosticWarn", { fg = colors.yellow })
	set(0, "DiagnosticInfo", { fg = colors.blue })
	set(0, "DiagnosticHint", { fg = colors.cyan })
	set(0, "DiagnosticOk", { fg = colors.green })
end

function M.reload()
	local config_home = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h")
	local path = first_readable({
		vim.fn.stdpath("config") .. "/colors/tinty.lua",
		config_home .. "/wezterm/colors/tinty.lua",
	})

	if not path then
		return false
	end

	local palette = load_palette(path)
	local colors = palette and normalize(palette)
	if not colors then
		return false
	end

	apply(colors)
	return true
end

function M.setup()
	M.reload()
	vim.api.nvim_create_user_command("TintyReload", M.reload, {
		desc = "Reload the tinty theme",
	})
end

return M
