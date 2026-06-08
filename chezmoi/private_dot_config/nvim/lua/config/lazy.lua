require("lazy").setup({
  spec = {
    -- upstream baseline
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- local authority surfaces
    { import = "plugins.core" },
    { import = "plugins.lang" },
    { import = "plugins.ui" },
    { import = "plugins.workflow" },
    { import = "plugins.disabled" },
  },

  defaults = {
    lazy = true,
    version = false,
  },

  checker = {
    enabled = true,
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
