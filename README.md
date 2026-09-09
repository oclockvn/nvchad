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
- **A C compiler + `make` on PATH** (mingw `gcc` recommended on Windows — MSVC `cl` needs the Windows SDK separately) — needed for Treesitter to compile the `c_sharp`/`xml` parsers, and for `telescope-fzf-native` to build `libfzf`
- **git** — needed for lazy.nvim's bootstrap clone

On Windows, the WinLibs bundle gives both `gcc` and `mingw32-make` with no
environment setup:

```bash
winget install BrechtSanders.WinLibs.POSIX.UCRT
```

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

## Telescope fuzzy finder — large-repo perf

NvChad ships Telescope with the pure-Lua sorter, which re-scores every
candidate on every keystroke — hundreds of ms of lag on Windows once a repo
is big. [`lua/plugins/init.lua`](lua/plugins/init.lua) fixes this:

- **`telescope-fzf-native`** — native C sorter, ~10-50x faster. Auto-builds
  via `make` on install/update (needs `gcc` + `make`, see prerequisites).
  Loaded from Telescope's own `config` so it always attaches.
- **`file_ignore_patterns`** — skips `bin/`, `obj/`, `.git/`, `.vs/`,
  `node_modules/`, generated `*.g.cs`.
- **preview** — Treesitter highlighting off + 1 MB filesize limit (regex
  highlight stays; the per-selection re-parse is what janked).
- **`find_files`** — explicit `fd` command.

Verify after launch (open a picker first — Telescope is lazy-loaded):

```
:Telescope find_files
:checkhealth telescope
```

Expect an `fzf` entry under **Installed extensions** with `lib working as
expected`. If the build failed you get a warning on startup and Telescope
falls back to the Lua sorter — rerun `:Lazy build telescope-fzf-native.nvim`
once `gcc`/`make` are on PATH.
