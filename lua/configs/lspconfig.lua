require("nvchad.configs.lspconfig").defaults()

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- C#/Razor LSP (Roslyn) is managed entirely by easy-dotnet.nvim — see
-- plugins/init.lua. It self-installs roslyn-language-server as a dotnet
-- global tool (sidesteps the broken Crashdummyy/mason-registry package) and
-- wires the HTML LSP (vscode-langservers-extracted) into Roslyn's Razor
-- cohosting bridge, which plain roslyn.nvim never did — that gap was the
-- cause of the extreme slowness/exceptions editing .razor files.
