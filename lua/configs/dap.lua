return function()
  local dap, dapui = require("dap"), require("dapui")

  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  local function netcoredbg_cmd()
    local base = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin", "netcoredbg")
    return vim.fn.executable(base .. ".cmd") == 1 and (base .. ".cmd") or base
  end

  local function nearest_csproj()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
      return nil
    end
    return vim.fs.find("*.csproj", { upward = true, path = path })[1]
  end

  local function find_program()
    local csproj = nearest_csproj()
    if csproj then
      local root = vim.fs.dirname(csproj)
      local name = vim.fn.fnamemodify(csproj, ":t:r")
      local dlls = vim.fn.globpath(root, "bin/**/" .. name .. ".dll", true, true)
      if #dlls > 0 then
        for _, dll in ipairs(dlls) do
          if dll:match("[/\\]Debug[/\\]") then
            return dll
          end
        end
        return dlls[#dlls]
      end
      vim.notify("No .dll yet. Run: dotnet build", vim.log.levels.WARN)
      return vim.fn.input("Path to built .dll: ", root .. "/bin/Debug/", "file")
    end
    return vim.fn.input("Path to built .dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
  end

  local adapter = {
    type = "executable",
    command = netcoredbg_cmd(),
    args = { "--interpreter=vscode" },
  }
  dap.adapters.coreclr = adapter
  -- .vscode/launch.json from C# Dev Kit uses type "dotnet", not "coreclr"
  dap.adapters.dotnet = adapter

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Launch (netcoredbg)",
      request = "launch",
      program = find_program,
      cwd = function()
        local csproj = nearest_csproj()
        return csproj and vim.fs.dirname(csproj) or vim.fn.getcwd()
      end,
    },
  }

  -- VS Code launch.json: dotnet + projectPath → coreclr + program (.dll)
  dap.providers.configs["dap.launch.json"] = function()
    local ok, configs = pcall(require("dap.ext.vscode").getconfigs)
    if not ok then
      return {}
    end
    for _, cfg in ipairs(configs) do
      if cfg.type == "dotnet" then
        cfg.type = "coreclr"
        if cfg.projectPath and not cfg.program then
          local proj = cfg.projectPath:gsub("${workspaceFolder}", vim.fn.getcwd())
          local root = vim.fs.dirname(proj)
          local name = vim.fn.fnamemodify(proj, ":t:r")
          local dlls = vim.fn.globpath(root, "bin/**/" .. name .. ".dll", true, true)
          for _, dll in ipairs(dlls) do
            if dll:match("[/\\]Debug[/\\]") then
              cfg.program = dll
              break
            end
          end
          cfg.program = cfg.program or dlls[#dlls]
          cfg.cwd = cfg.cwd or root
          cfg.projectPath = nil
        end
      end
    end
    return configs
  end

  local map = vim.keymap.set
  map("n", "<F5>", dap.continue, { desc = "DAP Continue" })
  map("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
  map("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
  map("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
end
