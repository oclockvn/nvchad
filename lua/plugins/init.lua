return {
  { import = "nvchad.blink.lazyspec" },

  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "seblyng/roslyn.nvim" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  { "seblyng/roslyn.nvim", opts = {} },

  {
    "mason-org/mason.nvim",
    opts = function()
      local opts = require "nvchad.configs.mason"
      opts.registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      }
      return opts
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "roslyn", "netcoredbg" },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
    config = function()
      require("configs.dap")()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      -- ponytail: Windows parser builds need a real compiler on PATH
      require("nvim-treesitter.install").compilers = { "clang", "cl", "gcc" }
    end,
    opts = function()
      local opts = require "nvchad.configs.treesitter"
      vim.list_extend(opts.ensure_installed, { "c_sharp", "xml", "json", "yaml", "markdown" })
      return opts
    end,
  },

  {
    "saghen/blink.cmp",
    opts = function()
      local opts = require "nvchad.blink.config"
      opts.keymap = vim.tbl_extend("force", opts.keymap or {}, {
        -- Windows terminals send Ctrl+Space as <C-@>/<Nul>
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-@>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Nul>"] = { "show", "show_documentation", "hide_documentation" },
      })
      return opts
    end,
  },
}
