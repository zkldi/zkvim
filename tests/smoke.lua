local function run()
  local notifications = {}
  local notify = vim.notify
  vim.notify = function(message, level, opts)
    if level == vim.log.levels.ERROR then
      notifications[#notifications + 1] = tostring(message)
    end
    notify(message, level, opts)
  end
  local ok, err = xpcall(function()
    assert(vim.env.NVIM_APPNAME == "zkvim")
    assert(vim.fn.fnamemodify(vim.fn.stdpath("config"), ":t") == "zkvim")
    assert(vim.g.colors_name == "vscode", "Theme did not load")
    assert(vim.g.autoformat == false, "Format on save must remain off")
    assert(vim.o.expandtab == false and vim.o.tabstop == 4 and vim.o.shiftwidth == 4)
    assert(vim.o.wrap and vim.o.relativenumber and not vim.o.autowrite)
    assert(vim.fn.exists(":ZkCommands") == 2, "Custom commands did not register")
    for _, mode in ipairs({ "n", "i", "x" }) do
      for _, lhs in ipairs({ "<C-s>", "<C-p>", "<C-S-p>", "<C-w>", "<C-j>", "<C-k>s" }) do
        assert(vim.fn.maparg(lhs, mode) ~= "", "Missing " .. mode .. " mapping: " .. lhs)
      end
    end
    local config = require("lazy.core.config")
    assert(not config.plugins["flash.nvim"], "Flash must not intercept s/S")
    assert(config.plugins["neo-tree.nvim"] and config.plugins["aerial.nvim"])
    local opts = require("lazy.core.plugin").values(config.plugins["snacks.nvim"], "opts", false)
    assert(opts.indent.enabled == false and opts.dashboard.enabled == false)
    assert(opts.terminal.win.keys.nav_j == false, "Shell Ctrl-J must not be intercepted")
    require("lazy").load({
      plugins = {
        "neo-tree.nvim",
        "aerial.nvim",
        "bufferline.nvim",
        "lualine.nvim",
        "blink.cmp",
        "grug-far.nvim",
        "gitsigns.nvim",
        "nvim-lspconfig",
        "vim-easymotion",
      },
    })
    for _, mode in ipairs({ "n", "x", "o" }) do
      assert(vim.fn.maparg("s", mode) == "<Plug>(easymotion-s)")
      assert(vim.fn.maparg("<Plug>(easymotion-s)", mode) ~= "")
    end
    local lsp = require("lazy.core.plugin").values(config.plugins["nvim-lspconfig"], "opts", false)
    assert(lsp.servers.vtsls and lsp.servers.biome and lsp.servers.eslint)
    local blink = require("blink.cmp.config")
    assert(blink.keymap["<C-p>"][1] == "fallback")
    assert(blink.keymap["<C-n>"][1] == "fallback")
    local panels = require("zkvim.panels")
    local editor = vim.api.nvim_get_current_win()
    local function tree_window()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
          return win
        end
      end
    end
    panels.show("filesystem", false)
    assert(tree_window(), "Project panel did not open")
    assert(vim.api.nvim_win_get_position(tree_window())[2] > vim.api.nvim_win_get_position(editor)[2])
    assert(vim.api.nvim_get_current_win() == editor, "Opening the sidebar stole editor focus")
    panels.show("filesystem")
    assert(not tree_window(), "Project panel did not toggle closed")
    panels.show("git_status", false)
    assert(tree_window(), "Git panel did not open")
    panels.show("outline", false)
    assert(not tree_window(), "Outline must replace the project/Git panel")
    assert(require("aerial").is_open(), "Outline panel did not open")
    panels.show("outline")
    assert(not require("aerial").is_open(), "Outline did not toggle closed")
    local shell = vim.o.shell
    vim.o.shell = "/bin/sh"
    panels.terminal()
    local terminals = Snacks.terminal.list()
    assert(#terminals == 1, "Bottom terminal did not open")
    local terminal = terminals[1]
    assert(vim.api.nvim_win_get_position(terminal.win)[1] > vim.api.nvim_win_get_position(editor)[1])
    panels.terminal()
    assert(not terminal:win_valid(), "Terminal did not hide")
    panels.terminal()
    assert(terminals[1].buf == Snacks.terminal.list()[1].buf, "Terminal process was not reused")
    vim.fn.chansend(vim.b[terminal.buf].terminal_job_id, "exit\n")
    assert(
      vim.wait(3000, function()
        return not terminal:buf_valid()
      end),
      "Test shell did not exit"
    )
    vim.o.shell = shell
    local errors = {}
    for name, plugin in pairs(config.plugins) do
      for _, task in ipairs(plugin._.tasks or {}) do
        if task.error then
          errors[#errors + 1] = name .. ": " .. tostring(task.error)
        end
      end
    end
    assert(#errors == 0, table.concat(errors, "\n"))
    assert(#notifications == 0, table.concat(notifications, "\n"))
    print("PASS profile isolation, options, theme, shortcuts, plugins, and language configuration")
  end, debug.traceback)
  if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
  end
  vim.cmd("qa!")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    vim.schedule(run)
  end,
})

-- Lazy waits for UIEnter; exercise the same lifecycle in a headless session.
vim.schedule(function()
  if not vim.g.did_very_lazy then
    vim.g.did_very_lazy = true
    vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
  end
end)
vim.defer_fn(function()
  io.stderr:write("Smoke test timed out\n")
  vim.cmd("cquit 1")
end, 30000)
