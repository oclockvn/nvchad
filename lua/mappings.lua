require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<Esc>", { silent = true })

-- LSP: methods in file + go to implementation (Roslyn)
map("n", "<leader>o", function()
  local telescope = require "telescope.builtin"
  if next(vim.lsp.get_clients { bufnr = 0 }) then
    telescope.lsp_document_symbols()
    return
  end
  -- Roslyn not attached yet (install / sln pick / still starting)
  local ok = pcall(telescope.treesitter)
  if not ok then
    vim.notify("No LSP client. Wait for Roslyn, or :MasonInstall roslyn", vim.log.levels.WARN)
  end
end, { desc = "document symbols" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP go to implementation" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
