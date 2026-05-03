return {
  {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    keys = {
      {
        "-",
        "<cmd>Oil<cr>",
        desc = "Open Parent Directory",
      },
    },
    opts = {
      default_file_explorer = false,
      delete_to_trash = false,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["q"] = "actions.close",
      },
    },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
  },
}
