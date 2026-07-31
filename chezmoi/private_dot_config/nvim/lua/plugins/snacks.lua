local function session_root()
	local root = vim.env.TERM_PROJECT_ROOT
	if type(root) == "string" and root ~= "" and vim.fn.isdirectory(root) == 1 then
		return root
	end

	return LazyVim.root()
end

local function config_home()
	return vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
end

local function trim(value)
	return value:match("^%s*(.-)%s*$")
end

local function expand_home(path)
	if path == "~" then
		return vim.env.HOME
	end

	if path:sub(1, 2) == "~/" then
		return vim.env.HOME .. path:sub(2)
	end

	if path:sub(1, 1) == "/" then
		return path
	end

	error("Invalid project seed path: " .. path .. "; expected ~, ~/..., or an absolute path")
end

local function seeded_projects()
	local seed_path = config_home() .. "/projects.seed"
	local file, err = io.open(seed_path, "r")

	if not file then
		error("Unable to read project seed " .. seed_path .. ": " .. tostring(err))
	end

	local projects = {}
	local seen = {}

	for line in file:lines() do
		local path = trim(line)

		if path ~= "" and path:sub(1, 1) ~= "#" then
			path = expand_home(path)
			if path ~= "/" then
				path = path:gsub("/+$", "")
			end

			if seen[path] then
				error("Duplicate project seed path: " .. path)
			end

			seen[path] = true

			if path ~= vim.env.HOME then
				table.insert(projects, path)
			end
		end
	end

	file:close()

	return projects
end

local function project_finder()
	local projects = seeded_projects()

	return function(cb)
		for _, path in ipairs(projects) do
			cb({
				file = path,
				text = path,
				dir = true,
			})
		end
	end
end

return {
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				enabled = true,
			},
			explorer = {
				enabled = true,
				replace_netrw = true,
				hidden = true,
			},
			picker = {
				sources = {
					explorer = {
						layout = {
							preset = "sidebar",
							preview = "main",
						},
					},
				},
				hidden = true,
			},
		},
		keys = {
			{
				"<leader>fp",
				function()
					Snacks.picker.projects({ finder = project_finder() })
				end,
				desc = "Projects",
			},
			{
				"<leader>fe",
				function()
					Snacks.explorer({ cwd = session_root() })
				end,
				desc = "Explorer Snacks (root dir)",
			},
			{
				"<leader>fE",
				function()
					Snacks.explorer()
				end,
				desc = "Explorer Snacks (cwd)",
			},
			{ "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
			{ "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
		},
	},
}
