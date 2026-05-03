return {
  {
    "mrjones2014/smart-splits.nvim",
    build = "./kitty/install-kittens.bash",
    lazy = false,
    init = function()
      vim.g.smart_splits_multiplexer_integration = "kitty"
    end,
    opts = {
      at_edge = "stop",
      default_amount = 3,
      cursor_follows_swapped_bufs = true,
      ignored_buftypes = {
        "nofile",
        "prompt",
        "quickfix",
        "terminal",
      },
      ignored_filetypes = {
        "NvimTree",
        "Trouble",
        "snacks_dashboard",
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
      },
      multiplexer_integration = "kitty",
    },
    keys = {
      { "<M-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move Left" },
      { "<M-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move Down" },
      { "<M-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move Up" },
      { "<M-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move Right" },
      { "<M-H>", function() require("smart-splits").resize_left() end, desc = "Resize Left" },
      { "<M-J>", function() require("smart-splits").resize_down() end, desc = "Resize Down" },
      { "<M-K>", function() require("smart-splits").resize_up() end, desc = "Resize Up" },
      { "<M-L>", function() require("smart-splits").resize_right() end, desc = "Resize Right" },
      { "<C-\\>", function() require("smart-splits").move_cursor_previous() end, desc = "Move to Previous Split" },
      { "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap Buffer Left" },
      { "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap Buffer Down" },
      { "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap Buffer Up" },
      { "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap Buffer Right" },
    },
  },
}
