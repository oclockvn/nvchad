require "nvchad.autocmds"

-- Stale :Roslyn target poisons gd when buffer csproj ∉ selected sln (e.g. TallyPowerTool vs legacy sln)
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = { "*.cs", "*.razor", "*.cshtml" },
  callback = function(args)
    local sln = vim.g.roslyn_nvim_selected_solution
    if not sln then
      return
    end
    local csproj = require("roslyn.sln.discovery").find_project(args.buf)
    if csproj and not require("roslyn.sln.api").exists_in_target(sln, csproj) then
      vim.g.roslyn_nvim_selected_solution = nil
    end
  end,
})

-- Format C# / Razor on save via Roslyn LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cs", "*.razor" },
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf, async = false })
  end,
})
