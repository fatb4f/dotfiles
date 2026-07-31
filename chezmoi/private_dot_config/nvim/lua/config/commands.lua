local uv = require("util.python_uv")

vim.api.nvim_create_user_command("UvPytest", function()
	uv.run_quickfix("pytest", { "--tb=short", "--color=no" }, uv.pytest_diagnostics)
end, { desc = "Run pytest with the project uv environment" })

vim.api.nvim_create_user_command("UvTyCheck", function()
	uv.run_quickfix(
		"ty",
		{ "check", "--output-format", "concise", "--no-progress", "--color", "never" },
		uv.ty_diagnostics
	)
end, { desc = "Run ty check with the project uv environment" })
