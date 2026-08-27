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
  -- Roslyn not attached yet (easy-dotnet still starting Roslyn)
  local ok = pcall(telescope.treesitter)
  if not ok then
    vim.notify("No LSP client. Wait for Roslyn to start.", vim.log.levels.WARN)
  end
end, { desc = "document symbols" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP go to implementation" })

local function lsp_or_warn(fn, label)
  return function()
    if not vim.lsp.get_clients({ bufnr = 0, name = "roslyn" })[1] then
      vim.notify("Roslyn not ready. Wait a few sec.", vim.log.levels.WARN)
      return
    end
    fn()
  end
end

map("n", "gd", lsp_or_warn(vim.lsp.buf.definition, "definition"), { desc = "LSP go to definition" })
map("n", "gr", lsp_or_warn(vim.lsp.buf.references, "references"), { desc = "LSP references" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Terminal: toggle (hide, don't close) a persistent horizontal term
map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggle horizontal" })

map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal toggle vertical" })

map({ "n", "t" }, "<A-f>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating" })

-- escape terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "terminal escape to normal mode" })
