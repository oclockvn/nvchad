return {
  { import = "nvchad.blink.lazyspec" },

  -- P3: not needed for .NET
  { "stevearc/conform.nvim", enabled = false },
  { "nvzone/minty", enabled = false },
  { "nvzone/volt", enabled = false },
  { "nvzone/menu", enabled = false },
  { "lewis6991/gitsigns.nvim", enabled = false },

  -- P4: lean snippets — Roslyn covers C# completion
  { "L3MON4D3/LuaSnip", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- C#/Razor: Roslyn LSP + Razor HTML cohosting bridge, self-managed as
  -- dotnet global tools (bypasses the broken Crashdummyy/mason-registry
  -- "roslyn" package entirely). Requires:
  --   dotnet tool install -g EasyDotnet
  --   npm install -g vscode-langservers-extracted   (Razor HTML bridge)
  -- Debugger/test-runner features intentionally left unused (lsp only).
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "razor", "cshtml", "fsproj", "csproj", "sln", "slnx" },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    opts = {
      lsp = {
        enabled = true,
        razor = {
          enabled = true,
          html = { enabled = true },
        },
      },
      picker = "telescope",
    },
  },

  {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {},
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local opts = require "nvchad.configs.treesitter"
      opts.ensure_installed = { "c_sharp", "xml" }
      return opts
    end,
    config = function(_, opts)
      -- ponytail: Windows parser builds need a real compiler on PATH
      require("nvim-treesitter.install").compilers = { "clang", "cl", "gcc" }
      require("nvim-treesitter").setup(opts)
    end,
  },

  {
    "saghen/blink.cmp",
    opts = function()
      local opts = require "nvchad.blink.config"
      opts.snippets = { preset = "default" } -- vim.snippet; no LuaSnip dep
      opts.sources = { default = { "lsp", "buffer", "path" } }
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
