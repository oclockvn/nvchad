require "nvchad.autocmds"

-- Format C# / Razor on save via Roslyn LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cs", "*.razor" },
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf, async = false })
  end,
})
