local child = vim.fn.jobstart({
  "env",
  "NVIM_APPNAME=zkvim",
  "nvim",
  "--embed",
  "--headless",
  "-i",
  "NONE",
}, { rpc = true })
assert(child > 0, "Could not start UI test instance")
local function lua(code)
  return vim.fn.rpcrequest(child, "nvim_exec_lua", code, {})
end
local function input(keys)
  vim.fn.rpcrequest(child, "nvim_input", keys)
  vim.wait(100, function()
    return false
  end)
end
local ok, err = xpcall(function()
  vim.fn.rpcrequest(child, "nvim_ui_attach", 140, 45, { rgb = true })
  assert(
    vim.wait(5000, function()
      return lua("return vim.g.did_very_lazy == true and vim.fn.exists(':ZkProject') == 2")
    end),
    "UI did not finish loading"
  )
  vim.wait(200, function()
    return false
  end)
  assert(
    lua([[
    local editor = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
        return vim.api.nvim_win_get_position(win)[2] > vim.api.nvim_win_get_position(editor)[2]
      end
    end
    return false
  ]]),
    "Startup sidebar is missing or not on the right"
  )
  assert(lua("return vim.g.colors_name == 'vscode'"), "UI theme did not load")
  local startup_error = lua("return vim.v.errmsg")
  -- Neo-tree silently clears netrw's group even when netrw is disabled.
  assert(
    startup_error == "" or startup_error == "E216: No such group or event: FileExplorer *",
    "UI startup error: " .. startup_error
  )
  print("PASS real UI startup and right sidebar")

  lua([[
    local clipboard = { { "" }, "v" }
    vim.g.clipboard = {
      name = "zkvim-ui-test",
      copy = {
        ["+"] = function(lines, kind) clipboard = { lines, kind } end,
        ["*"] = function(lines, kind) clipboard = { lines, kind } end,
      },
      paste = {
        ["+"] = function() return clipboard end,
        ["*"] = function() return clipboard end,
      },
    }
    require("zkvim.panels").show("filesystem")
  ]])
  input("ihello")
  assert(lua("return vim.api.nvim_get_current_line() == 'hello' and vim.fn.mode() == 'i'"))
  input("<C-p>")
  assert(lua("return #Snacks.picker.get({ source = 'files' }) == 1"), "Insert Ctrl-P was intercepted by completion")
  lua("Snacks.picker.get()[1]:close()")
  input("<Esc><C-S-p>")
  assert(lua("return #Snacks.picker.get({ source = 'commands' }) == 1"), "Command palette did not open")
  lua("Snacks.picker.get()[1]:close()")
  print("PASS file finder and command palette keybindings")

  input("<Esc><C-a><C-c>")
  assert(lua("return vim.fn.getreg('+'):find('hello', 1, true) ~= nil"), "Select-all/copy did not reach clipboard")
  input("<Esc>i<C-d>")
  assert(lua("return vim.api.nvim_get_current_line() == ''"), "Insert Ctrl-D did not cut the line")
  input("<C-v>")
  assert(
    lua("return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == 'hello' and vim.fn.mode() == 'i'"),
    "Insert paste did not restore the cut line"
  )
  input("<Esc>")
  print("PASS insert editing and clipboard shortcuts")
  lua("vim.bo.commentstring = '-- %s'")
  input("gg<C-_>")
  assert(lua("return vim.api.nvim_get_current_line() == '-- hello'"), "Legacy Ctrl-/ encoding did not comment")
  print("PASS terminal-compatible comment shortcut")
  lua([[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one two xyz" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  ]])
  input("sz")
  assert(lua("return vim.api.nvim_win_get_cursor(0)[2] == 10"), "s plus a character did not jump")
  print("PASS single-character EasyMotion shortcut")
end, debug.traceback)

-- This is the instance created by this test, never an existing editor session.
vim.fn.rpcnotify(child, "nvim_exec_lua", "vim.cmd('qa!')", {})
local status = vim.fn.jobwait({ child }, 5000)[1]
if not ok or status ~= 0 then
  io.stderr:write((err or "UI test instance did not exit cleanly") .. "\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
