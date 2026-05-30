return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    init = function()
      vim.g.smart_splits_multiplexer_integration = "wezterm"

      local in_wezterm = vim.env.TERM_PROGRAM == "WezTerm" or vim.env.WEZTERM_PANE ~= nil
      if not in_wezterm then
        return
      end

      local values = {
        ["true"] = "dHJ1ZQ==",
        ["false"] = "ZmFsc2U=",
      }

      local function set_is_nvim(value)
        io.stdout:write("\027]1337;SetUserVar=IS_NVIM=" .. values[value] .. "\007")
        io.stdout:flush()
      end

      vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
        group = vim.api.nvim_create_augroup("dotfiles_wezterm_is_nvim", { clear = true }),
        callback = function()
          set_is_nvim("true")
        end,
      })

      vim.api.nvim_create_autocmd({ "VimLeavePre", "FocusLost" }, {
        group = vim.api.nvim_create_augroup("dotfiles_wezterm_is_not_nvim", { clear = true }),
        callback = function()
          set_is_nvim("false")
        end,
      })
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
      multiplexer_integration = "wezterm",
    },
    keys = {
      -- WezTerm mirrors this contract: Ctrl+h/j/k/l moves, Alt+h/j/k/l resizes.
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move Left" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move Down" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move Up" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move Right" },
      { "<M-h>", function() require("smart-splits").resize_left() end, desc = "Resize Left" },
      { "<M-j>", function() require("smart-splits").resize_down() end, desc = "Resize Down" },
      { "<M-k>", function() require("smart-splits").resize_up() end, desc = "Resize Up" },
      { "<M-l>", function() require("smart-splits").resize_right() end, desc = "Resize Right" },
      { "<C-\\>", function() require("smart-splits").move_cursor_previous() end, desc = "Move to Previous Split" },
      { "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap Buffer Left" },
      { "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap Buffer Down" },
      { "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap Buffer Up" },
      { "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap Buffer Right" },
    },
  },
}
