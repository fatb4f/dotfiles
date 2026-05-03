return {
  "tinted-theming/tinted-nvim",
  priority = 1000, -- load colorscheme early
  lazy = false, -- apply on startup
  opts = {
    default_scheme = "base16-darkviolet", -- pick any bundled Base16/Base24
    -- compile = true, -- optional: precompile for faster startup
  },
}
