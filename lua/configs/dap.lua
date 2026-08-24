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

  dap.adapters.coreclr = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Launch (netcoredbg)",
      request = "launch",
      program = function()
        return vim.fn.input("Path to built .dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
    },
  }

  local map = vim.keymap.set
  map("n", "<F5>", dap.continue, { desc = "DAP Continue" })
  map("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
  map("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
  map("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
end
