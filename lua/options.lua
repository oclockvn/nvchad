require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

local o = vim.o
o.ignorecase = true
o.smartcase = true

-- use PowerShell for :terminal instead of cmd
if vim.fn.executable "pwsh" == 1 then
  o.shell = "pwsh"
elseif vim.fn.executable "powershell" == 1 then
  o.shell = "powershell"
end

if o.shell == "pwsh" or o.shell == "powershell" then
  o.shellcmdflag =
    "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  o.shellquote = ""
  o.shellxquote = ""
end

vim.filetype.add({
  extension = {
    razor = "razor",
    cshtml = "razor",
    csproj = "xml",
    props = "xml",
    targets = "xml",
  },
})
