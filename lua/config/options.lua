vim.g.autoformat = false
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_explorer = "neo-tree"
vim.g.lazyvim_cmp = "blink.cmp"
vim.g.trouble_lualine = false

local opt = vim.opt
opt.autowrite = false
opt.autowriteall = false
opt.background = "dark"
opt.clipboard = "unnamedplus"
opt.confirm = true
opt.expandtab = false
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.wrap = true
opt.linebreak = true
opt.textwidth = 0
opt.colorcolumn = ""
opt.number = true
opt.relativenumber = true
opt.conceallevel = 0
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣", leadmultispace = "·   " }
opt.cursorline = true
opt.guicursor = "n-v-c-sm:block-blinkon0,i-ci-ve:ver25-blinkon0,r-cr-o:hor20-blinkon0"
opt.mouse = "a"
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.showtabline = 2
opt.laststatus = 3
opt.pumblend = 0
opt.winblend = 0
opt.timeoutlen = 500
opt.inccommand = "split"
opt.fixendofline = true
if vim.fn.executable("fish") == 1 then
  opt.shell = vim.fn.exepath("fish")
end
