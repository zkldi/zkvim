return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    opts = {
      close_if_last_window = false,
      enable_git_status = true,
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem", display_name = "Files" },
          { source = "git_status", display_name = "Git" },
          { source = "buffers", display_name = "Buffers" },
        },
      },
      window = { position = "right", width = 34 },
      filesystem = {
        hijack_netrw_behavior = "open_current",
        follow_current_file = { enabled = true },
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true },
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    branch = vim.fn.has("nvim-0.12") == 1 and "master" or "nvim-0.11",
    opts = {
      layout = { default_direction = "right", placement = "edge", min_width = 30, max_width = 40 },
      show_guides = false,
      open_automatic = false,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 600, virt_text_pos = "eol" },
    },
  },
}
