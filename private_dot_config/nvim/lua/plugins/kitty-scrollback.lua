return {
  {
    "mikesmithgh/kitty-scrollback.nvim",
    lazy = true,
    cmd = {
      "KittyScrollbackGenerateKittens",
      "KittyScrollbackCheckHealth",
      "KittyScrollbackGenerateCommandLineEditing",
    },
    opts = {
      restore_options = true,
      scrollback_columns = 500,
      visual_selection_highlight_mode = "kitty",
      status_window = {
        enabled = true,
        autoclose = true,
        show_timer = false,
        style_simple = false,
      },
      paste_window = {
        filetype = "bash",
        hide_footer = false,
        winblend = 0,
        yank_register_enabled = true,
      },
      screen_auto = function(kitty_data)
        return {
          kitty_get_text = {
            ansi = true,
            extent = (kitty_data.scrolled_by > kitty_data.lines) and "all" or "screen",
            clear_selection = false,
          },
        }
      end,
      all_ansi = {
        kitty_get_text = {
          ansi = true,
          extent = "all",
          clear_selection = true,
        },
      },
      selection_keep = {
        kitty_get_text = {
          ansi = true,
          extent = "selection",
          clear_selection = false,
        },
      },
      first_cmd_output_on_screen = {
        kitty_get_text = {
          ansi = true,
          extent = "first_cmd_output_on_screen",
        },
      },
      last_cmd_output = {
        kitty_get_text = {
          ansi = true,
          extent = "last_cmd_output",
        },
      },
      last_non_empty_output = {
        kitty_get_text = {
          ansi = true,
          extent = "last_non_empty_output",
        },
      },
      last_visited_cmd_output = {
        kitty_get_text = {
          ansi = true,
          extent = "last_visited_cmd_output",
        },
      },
    },
  },
}
