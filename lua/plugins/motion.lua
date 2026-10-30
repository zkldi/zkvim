return {
  {
    "easymotion/vim-easymotion",
    init = function()
      vim.g.EasyMotion_do_mapping = 0
      vim.g.EasyMotion_smartcase = 1
    end,
    keys = {
      {
        "s",
        "<Plug>(easymotion-s)",
        mode = { "n", "x", "o" },
        desc = "EasyMotion character",
      },
    },
  },
}
