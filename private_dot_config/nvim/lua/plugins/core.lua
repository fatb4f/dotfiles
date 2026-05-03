return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tinted",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          filetypes = { "bash", "sh" },
          root_markers = { ".bashly.yml", ".bashly.yaml", ".git" },
        },
        cue_ls = {
          cmd = { "cue", "lsp", "serve" },
          filetypes = { "cue" },
          root_markers = { "cue.mod", ".git" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash-language-server",
        "prettier",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
      })
    end,
  },
}
