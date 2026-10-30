local group = vim.api.nvim_create_augroup("ZkVim", { clear = true })

-- LazyVim's prose defaults differ from the user's Zed settings.
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.wrap = true
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = group,
  callback = function(event)
    require("zkvim.actions").remember_closed(event.buf)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "LazyVimKeymaps",
  once = true,
  callback = function()
    vim.schedule(function()
      if #vim.api.nvim_list_uis() == 0 or vim.env.ZKVIM_NO_SIDEBAR == "1" then
        return
      end
      require("zkvim.panels").show("filesystem", false)
    end)
  end,
})

require("zkvim.actions").commands()
