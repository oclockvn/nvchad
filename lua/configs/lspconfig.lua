require("nvchad.configs.lspconfig").defaults()

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- Roslyn: C# + Razor (cohosted). cmd/filetypes come from roslyn.nvim.
vim.lsp.config("roslyn", {
  capabilities = capabilities,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
  },
})
