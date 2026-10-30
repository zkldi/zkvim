local M = {}
local closed = {}

local function normal(keys)
  vim.cmd.normal({ keys, bang = true })
end

function M.remember_closed(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype == "" and name ~= "" and vim.fn.filereadable(name) == 1 then
    if closed[#closed] ~= name then
      closed[#closed + 1] = name
    end
    if #closed > 20 then
      table.remove(closed, 1)
    end
  end
end

function M.reopen()
  while #closed > 0 do
    local name = table.remove(closed)
    if vim.fn.filereadable(name) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(name))
      return
    end
  end
  vim.notify("No closed files to reopen", vim.log.levels.INFO)
end

function M.save()
  if vim.bo.buftype ~= "" then
    return
  end
  if vim.api.nvim_buf_get_name(0) == "" then
    vim.ui.input({ prompt = "Save as: ", completion = "file" }, function(name)
      if name and name ~= "" then
        vim.cmd.write(vim.fn.fnameescape(vim.fn.fnamemodify(name, ":p")))
      end
    end)
  else
    vim.cmd.write()
  end
end

function M.close()
  Snacks.bufdelete()
end

function M.copy()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    normal('"+y')
  else
    normal('"+yy')
  end
end

function M.cut()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    normal('"+d')
  else
    normal('"+dd')
  end
end

function M.paste()
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end

function M.find()
  Snacks.picker.lines({ title = "Find in File" })
end

function M.replace()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Save this file before using file-scoped replace", vim.log.levels.WARN)
    return
  end
  require("grug-far").open({
    transient = true,
    prefills = { paths = path },
  })
end

function M.open()
  vim.ui.input({ prompt = "Open file or directory: ", completion = "file" }, function(path)
    if not path or path == "" then
      return
    end
    path = vim.fn.fnamemodify(path, ":p")
    if vim.fn.isdirectory(path) == 1 then
      vim.cmd.cd(vim.fn.fnameescape(path))
      require("zkvim.panels").show("filesystem", false)
    else
      vim.cmd.edit(vim.fn.fnameescape(path))
    end
  end)
end

function M.goto_line()
  vim.ui.input({ prompt = "Go to line: " }, function(value)
    local line = tonumber(value)
    if line and line >= 1 then
      vim.api.nvim_win_set_cursor(0, { math.min(math.floor(line), vim.api.nvim_buf_line_count(0)), 0 })
      vim.cmd.normal({ "zvzz", bang = true })
    end
  end)
end

function M.newline(above)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
  local index = above and row - 1 or row
  vim.api.nvim_buf_set_lines(0, index, index, false, { indent })
  vim.api.nvim_win_set_cursor(0, { index + 1, #indent })
  vim.cmd.startinsert({ bang = true })
end

function M.activate_second_pane()
  local wins = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
  end, vim.api.nvim_tabpage_list_wins(0))
  table.sort(wins, function(a, b)
    return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
  end)
  if wins[2] then
    vim.api.nvim_set_current_win(wins[2])
  else
    vim.cmd("rightbelow vsplit")
  end
end

function M.check_key()
  vim.notify("Press a shortcut (Escape cancels). Neovim will display what iTerm2 sends.")
  vim.cmd.redraw()
  local ok, key = pcall(vim.fn.getcharstr)
  if ok then
    vim.notify(vim.fn.keytrans(key), vim.log.levels.INFO, { title = "Key received" })
  end
end

function M.commands()
  local panels = require("zkvim.panels")
  local commands = {
    ZkFiles = {
      function()
        Snacks.picker.files({ cwd = LazyVim.root() })
      end,
      "Find files",
    },
    ZkCommands = {
      function()
        Snacks.picker.commands()
      end,
      "Command palette",
    },
    ZkProject = {
      function()
        panels.show("filesystem")
      end,
      "Toggle project panel",
    },
    ZkOutline = {
      function()
        panels.show("outline")
      end,
      "Toggle outline panel",
    },
    ZkGit = {
      function()
        panels.show("git_status")
      end,
      "Toggle Git panel",
    },
    ZkTerminal = { panels.terminal, "Toggle bottom terminal" },
    ZkFind = { M.find, "Find in current file" },
    ZkReplace = { M.replace, "Replace in current file" },
    ZkReopen = { M.reopen, "Reopen closed file" },
    ZkCheckKey = { M.check_key, "Inspect an iTerm2 shortcut" },
    ZkKeys = {
      function()
        Snacks.picker.keymaps()
      end,
      "Search keybindings",
    },
  }
  for name, command in pairs(commands) do
    vim.api.nvim_create_user_command(name, command[1], { desc = command[2], force = true })
  end
end

return M
