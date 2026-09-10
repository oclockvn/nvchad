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
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "live_grep_args"
    end,
  },

  -- Perf: large repos. NvChad ships telescope with the pure-Lua fuzzy sorter,
  -- which re-scores every candidate on every keystroke (hundreds of ms on
  -- Windows once the file list is big). Native fzf sorter = ~10-50x faster.
  -- Build needs CMake + a C compiler on PATH. gcc via WinLibs:
  --   winget install BrechtSanders.WinLibs.POSIX.UCRT
  -- CMake (not `make`): the Makefile's Windows-native branch runs
  -- `cmd /C mkdir build`, which returns nonzero when build/ already exists
  -- (stale dir from a prior run) and aborts before compiling. CMake
  -- reconfigures an existing build dir without complaint.
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    -- `-G "MinGW Makefiles"`: CMake otherwise defaults to the NMake/VS
    -- generator on Windows and fails ("nmake: no such file"). This box
    -- has WinLibs gcc + mingw32-make, no MSVC.
    build = 'cmake -S. -Bbuild -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release '
      .. "&& cmake --build build --config Release "
      .. "&& cmake --install build --prefix build",
    lazy = true,
  },

  -- Trim the candidate set + kill preview jank in big .NET trees, and swap in
  -- the native fzf sorter. Own `config` so the extension loads with telescope
  -- (fzf-native has no lazy trigger of its own).
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.file_ignore_patterns = {
        "%.git[/\\]",
        "[/\\]bin[/\\]",
        "[/\\]obj[/\\]",
        "node_modules",
        "%.vs[/\\]",
        "%.g%.cs$",
      }
      opts.defaults.path_display = { "truncate" }
      -- regex highlight is cheap; treesitter re-parse on every selection move is not
      opts.defaults.preview = vim.tbl_extend("force", opts.defaults.preview or {}, {
        treesitter = false,
        filesize_limit = 1, -- MB; skip preview for huge generated files
      })
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--color", "never" },
        },
      })
      opts.extensions = vim.tbl_deep_extend("force", opts.extensions or {}, {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
        },
      })
      return opts
    end,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      local dir = require("lazy.core.config").plugins["telescope-fzf-native.nvim"].dir
      if vim.fn.glob(dir .. "/build/libfzf.*") ~= "" then
        pcall(telescope.load_extension, "fzf")
      else
        vim.notify("telescope-fzf-native not built - run :Lazy build telescope-fzf-native.nvim", vim.log.levels.WARN)
      end
    end,
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
