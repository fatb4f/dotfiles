local uv = require("util.python_uv")

vim.api.nvim_create_user_command("UvPytest", function(command)
	local target = command.fargs[1]
	local recipe = target:find("::", 1, true) and "test-node" or target:match("%.py$") and "test-file" or "test"
	local args = { "just", recipe, target }
	vim.list_extend(args, vim.list_slice(command.fargs, 2))
	uv.run_quickfix_command(args, uv.pytest_diagnostics)
end, {
	nargs = "+",
	complete = "file",
	desc = "Run an exercise, pytest file, or node through the project just workflow",
})

vim.api.nvim_create_user_command("UvTyCheck", function()
	uv.run_quickfix(
		"ty",
		{ "check", "--output-format", "concise", "--no-progress", "--color", "never" },
		uv.ty_diagnostics
	)
end, { desc = "Run ty check with the project uv environment" })
