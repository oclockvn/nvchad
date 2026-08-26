**This repo is supposed to be used as config by NvChad users!**

- The main nvchad repo (NvChad/NvChad) is used as a plugin by this repo.
- So you just import its modules , like `require "nvchad.options" , require "nvchad.mappings"`
- So you can delete the .git from this repo ( when you clone it locally ) or fork it :)

# Credits

1) Lazyvim starter https://github.com/LazyVim/starter as nvchad's starter was inspired by Lazyvim's . It made a lot of things easier!

# .NET Setup

This config is set up for .NET/C#/Razor development via
[easy-dotnet.nvim](https://github.com/GustavEikaas/easy-dotnet.nvim), which
manages the Roslyn language server itself (not Mason — the
`Crashdummyy/mason-registry` `roslyn` package is broken on Windows: bad
`.cmd` shim + missing `runtimeconfig.json` in the release asset).

## Prerequisites (install manually, not via CLI one-liner)

- **.NET SDK** — https://dotnet.microsoft.com/download
- **Node.js** (or Volta) — needed for the Razor HTML LSP bridge
- **A C compiler on PATH** (MSVC Build Tools `cl`, `clang`, or mingw `gcc`) — needed for Treesitter to compile the `c_sharp`/`xml` parsers on Windows
- **git** — needed for lazy.nvim's bootstrap clone

## Install commands

```bash
dotnet tool install -g EasyDotnet
```

```bash
npm install -g vscode-langservers-extracted
```

Then clone this config to `%LOCALAPPDATA%\nvim` and just launch:

```bash
nvim
```

`lazy.nvim` bootstraps itself and installs all plugins (including
`easy-dotnet.nvim`, which self-installs `roslyn-language-server` as a dotnet
global tool on first `.cs`/`.razor` file open).

Optional, only for editing this config itself:

```
:MasonInstall lua-language-server stylua
```

`netcoredbg` and a direct `roslyn-language-server` dotnet-tool install are
**not** required — debugging is intentionally left out of this config
(speed-first, LSP-only), and easy-dotnet.nvim manages Roslyn on its own.
