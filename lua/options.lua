require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

local o = vim.o
o.ignorecase = true
o.smartcase = true

vim.filetype.add({
  extension = {
    razor = "razor",
    cshtml = "razor",
    csproj = "xml",
    props = "xml",
    targets = "xml",
  },
})
