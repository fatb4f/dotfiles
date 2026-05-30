return {
  "tinted-theming/tinted-nvim",
  priority = 1000,
  lazy = false,
  opts = {
    default_scheme = "base16-papercolor-light",
    apply_scheme_on_startup = false,
    compile = true,
    selector = {
      enabled = true,
      mode = "file",
      path = "~/.local/share/tinted-theming/tinty/current_scheme",
      watch = true,
    },
  },
}
