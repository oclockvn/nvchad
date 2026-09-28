-- Minimal setup for vscode-neovim (Cursor/VS Code). No plugins: NvChad's
-- statusline/tabufline/icons render PUA glyphs that VS Code's own status
-- bar draws in its system UI font (tofu boxes), so skip the whole plugin
-- stack here and keep only editing-behavior options/mappings.

local o = vim.o
o.ignorecase = true
o.smartcase = true

local map = vim.keymap.set
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<Esc>", { silent = true })
