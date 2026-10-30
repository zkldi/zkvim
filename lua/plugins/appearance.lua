return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      italic_comments = false,
      color_overrides = {
        vscBack = "#1F1F1F",
        vscFront = "#CCCCCC",
        vscLeftDark = "#181818",
        vscTabOther = "#181818",
        vscTabOutside = "#181818",
        vscLineNumber = "#6E7681",
        vscSplitDark = "#2B2B2B",
      },
      group_overrides = {
        NeoTreeNormal = { fg = "#CCCCCC", bg = "#181818" },
        NeoTreeNormalNC = { fg = "#CCCCCC", bg = "#181818" },
        NeoTreeEndOfBuffer = { fg = "#181818", bg = "#181818" },
        NormalFloat = { fg = "#CCCCCC", bg = "#252526" },
        WinSeparator = { fg = "#2B2B2B", bg = "NONE" },
        CursorLine = { bg = "#282828" },
        CursorLineNr = { fg = "#CCCCCC" },
        BufferLineFill = { bg = "#181818" },
        BufferLineBufferSelected = { fg = "#FFFFFF", bg = "#1F1F1F", bold = false, italic = false },
        BufferLineIndicatorSelected = { fg = "#007ACC", bg = "#1F1F1F" },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        separator_style = "thin",
        indicator = { style = "underline" },
        show_buffer_close_icons = true,
        show_close_icon = false,
        offsets = { { filetype = "neo-tree", text = "Project", text_align = "left" } },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = ""
      opts.options.section_separators = ""
      opts.sections.lualine_z = {}
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      scroll = { enabled = false },
      animate = { enabled = false },
      words = { enabled = false },
      terminal = {
        win = {
          position = "bottom",
          height = 0.3,
          keys = { nav_h = false, nav_j = false, nav_k = false, nav_l = false },
        },
      },
      picker = {
        layout = { preset = "default" },
        win = {
          input = {
            keys = {
              ["<C-p>"] = { "list_up", mode = { "i", "n" } },
              ["<C-n>"] = { "list_down", mode = { "i", "n" } },
              ["<Esc>"] = { "close", mode = { "i", "n" } },
            },
          },
        },
      },
    },
  },
  { "folke/flash.nvim", enabled = false },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>z", group = "zkvim" } } },
  },
}
