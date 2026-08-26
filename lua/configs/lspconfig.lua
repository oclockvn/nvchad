require("nvchad.configs.lspconfig").defaults()

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- Pin Mason binary. roslyn.nvim falls back to Microsoft.CodeAnalysis.LanguageServer
-- (not on PATH) → lsp.log: "is not executable" and no client.
local mason_roslyn = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin", "roslyn-language-server.cmd")
local roslyn = {
  capabilities = capabilities,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
  },
}
if vim.fn.executable(mason_roslyn) == 1 then
  roslyn.cmd = { mason_roslyn, "--stdio" }
end
vim.lsp.config("roslyn", roslyn)

-- roslyn.nvim on_init is a list; it replaces NvChad * on_init, so tokens stay on.
-- Roslyn then dies on textDocument/semanticTokens/range (line N of N-line file).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "roslyn" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
