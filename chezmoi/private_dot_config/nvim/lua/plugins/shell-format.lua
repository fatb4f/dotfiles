return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.shellharden = {
        command = "shellharden",
        args = { "--transform", "" },
        stdin = true,
      }
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sh = { "shellharden", "shfmt" }
      opts.formatters_by_ft.bash = { "shellharden", "shfmt" }
      opts.format_on_save = opts.format_on_save or {}
      opts.format_on_save.timeout_ms = 2000
      opts.format_on_save.lsp_format = "fallback"
    end,
  },
}
