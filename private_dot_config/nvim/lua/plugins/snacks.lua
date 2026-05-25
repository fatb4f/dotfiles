return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      require("snacks.input").enable()
      vim.ui.select = require("snacks.picker").select
      vim.notify = require("snacks.notifier").notify
    end,
  },
}
