vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.swapfile = false
local clipboard = { { "" }, "v" }
vim.g.clipboard = {
  name = "zkvim-test",
  copy = {
    ["+"] = function(lines, kind)
      clipboard = { lines, kind }
    end,
    ["*"] = function(lines, kind)
      clipboard = { lines, kind }
    end,
  },
  paste = {
    ["+"] = function()
      return clipboard
    end,
    ["*"] = function()
      return clipboard
    end,
  },
}

local actions = require("zkvim.actions")
local count = 0
local temporary = {}
local function eq(expected, actual)
  assert(vim.deep_equal(expected, actual), "Expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end
local function test(name, run)
  vim.cmd("silent! only!")
  vim.cmd.enew({ bang = true })
  vim.cmd.stopinsert()
  run()
  count = count + 1
  print("PASS " .. name)
end
local function lines(values)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, values)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end
local function temp()
  local path = vim.fn.tempname()
  temporary[#temporary + 1] = path
  return path
end

local ok, err = xpcall(function()
  test("copy and cut whole lines", function()
    lines({ "first", "second" })
    actions.copy()
    eq("first\n", vim.fn.getreg("+"))
    actions.cut()
    eq({ "second" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    eq("first\n", vim.fn.getreg("+"))
  end)
  test("copy and cut a visual selection", function()
    lines({ "hello world" })
    vim.cmd.normal({ "v4l", bang = true })
    actions.copy()
    eq("hello", vim.fn.getreg("+"))
    vim.cmd.normal({ "0v4l", bang = true })
    actions.cut()
    eq({ " world" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)
  test("paste text literally", function()
    lines({ "" })
    vim.fn.setreg("+", "a\nb")
    actions.paste()
    eq({ "a", "b" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)
  test("newline below preserves hard-tab indent", function()
    lines({ "\tvalue", "next" })
    actions.newline(false)
    vim.cmd.stopinsert()
    eq({ "\tvalue", "\t", "next" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    eq(2, vim.api.nvim_win_get_cursor(0)[1])
  end)
  test("newline above first line", function()
    lines({ "  value" })
    actions.newline(true)
    vim.cmd.stopinsert()
    eq({ "  ", "  value" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)
  test("save existing file and ensure final newline", function()
    local path = temp()
    vim.api.nvim_buf_set_name(0, path)
    lines({ "saved" })
    actions.save()
    eq({ "saved" }, vim.fn.readfile(path))
    eq("saved\n", table.concat(vim.fn.readfile(path, "b"), "\n"))
  end)
  test("save unnamed buffer via prompt", function()
    local path = temp() .. " with spaces"
    temporary[#temporary + 1] = path
    lines({ "new file" })
    local input = vim.ui.input
    vim.ui.input = function(_, callback)
      callback(path)
    end
    actions.save()
    vim.ui.input = input
    eq(vim.uv.fs_realpath(path), vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)))
    eq({ "new file" }, vim.fn.readfile(path))
  end)
  test("cancel save leaves buffer unnamed", function()
    local input = vim.ui.input
    vim.ui.input = function(_, callback)
      callback(nil)
    end
    actions.save()
    vim.ui.input = input
    eq("", vim.api.nvim_buf_get_name(0))
  end)
  test("reopen closed file with spaces", function()
    local path = temp() .. " with spaces"
    temporary[#temporary + 1] = path
    vim.fn.writefile({ "reopen" }, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    actions.remember_closed(vim.api.nvim_get_current_buf())
    vim.cmd.enew()
    actions.reopen()
    eq(vim.uv.fs_realpath(path), vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)))
  end)
  test("go to line clamps to file length", function()
    lines({ "one", "two" })
    local input = vim.ui.input
    vim.ui.input = function(_, callback)
      callback("999")
    end
    actions.goto_line()
    vim.ui.input = input
    eq(2, vim.api.nvim_win_get_cursor(0)[1])
  end)
  test("second pane is created then reused", function()
    actions.activate_second_pane()
    eq(2, #vim.api.nvim_tabpage_list_wins(0))
    local second = vim.api.nvim_get_current_win()
    vim.cmd.wincmd("h")
    actions.activate_second_pane()
    eq(second, vim.api.nvim_get_current_win())
    eq(2, #vim.api.nvim_tabpage_list_wins(0))
  end)
  test("commands register without invoking UI", function()
    actions.commands()
    eq(2, vim.fn.exists(":ZkCheckKey"))
    eq(2, vim.fn.exists(":ZkProject"))
  end)
end, debug.traceback)
for _, path in ipairs(temporary) do
  vim.fn.delete(path)
end
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print(("Passed %d unit tests"):format(count))
vim.cmd("qa!")
