local M = {}
local active_source

function M.show(source, toggle)
  local command = require("neo-tree.command")
  if source == "outline" then
    local aerial = require("aerial")
    if aerial.is_open() and toggle ~= false then
      aerial.close()
      active_source = nil
      return
    end
    command.execute({ action = "close" })
    aerial.open({ focus = false })
  else
    require("aerial").close()
    command.execute({
      action = "show",
      toggle = toggle ~= false and active_source == source,
      source = source,
      position = "right",
      dir = LazyVim.root(),
    })
  end
  active_source = source
end

function M.terminal()
  local current = vim.api.nvim_get_current_buf()
  for _, terminal in ipairs(Snacks.terminal.list()) do
    if terminal.buf == current then
      terminal:hide()
      return
    end
  end
  Snacks.terminal.toggle(nil, {
    cwd = LazyVim.root(),
    win = { position = "bottom", height = 0.3, border = "top", wo = { winbar = "" } },
  })
end

return M
