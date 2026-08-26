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

  -- broad_search: find .sln under git root. Without it, no sln → FileBasedPrograms
  -- (Temp\roslyn-canonical-misc\Canonical.csproj) and "unresolved dependencies".
  { "seblyng/roslyn.nvim", opts = { broad_search = true } },

  {
    "mason-org/mason.nvim",
    lazy = false, -- installer needs registry before Roslyn starts
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
    lazy = false, -- NvChad defaults.lazy=true; no event = never ran, roslyn never installed
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "roslyn", "netcoredbg" },
    },
  },

  {
    "mfussenegger/nvim-dap",
    ft = { "cs", "razor" },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
    },
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
