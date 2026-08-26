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
    dependencies = {
      {
        "seblyng/roslyn.nvim",
        -- broad_search: find .sln under git root. Without it, no sln → FileBasedPrograms
        -- (Temp\roslyn-canonical-misc\Canonical.csproj) and "unresolved dependencies".
        opts = {
          broad_search = true,
          choose_target = function(targets)
            local csproj = require("roslyn.sln.discovery").find_project(vim.api.nvim_get_current_buf())
            if not csproj then
              return targets[1]
            end
            local sln_api = require "roslyn.sln.api"
            for _, target in ipairs(targets) do
              if sln_api.exists_in_target(target, csproj) then
                return target
              end
            end
            return nil -- no sln owns this csproj → project/open mode
          end,
        },
      },
    },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
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
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "roslyn" },
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
