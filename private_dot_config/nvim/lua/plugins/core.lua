return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tinted",
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "cue",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
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
        "basedpyright",
        "debugpy",
        "prettier",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
      })
    end,
  },
}
