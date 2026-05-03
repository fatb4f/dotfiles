return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local install = require("nvim-treesitter.install")
      install.compilers = { "gcc", "cc", "clang", "zig" }
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "css",
        "html",
        "javascript",
        "latex",
        "regex",
        "scss",
        "svelte",
        "tsx",
        "typst",
        "vue",
      })
    end,
  },
}
