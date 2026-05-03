return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      require("snacks.input").enable()
      vim.notify = require("snacks.notifier").notify
    end,
  },
}
