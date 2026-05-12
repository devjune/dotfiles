-- ============================================
-- Neovim Config (init.lua)
-- ============================================

-- --- Leader ---
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --- Options ---
local opt = vim.opt

-- Display
opt.number = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.termguicolors = true
opt.showmatch = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Editing
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.autoindent = true
opt.smartindent = true

-- UX
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.updatetime = 300

-- Persistent undo (no swap/backup files)
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- --- Bootstrap lazy.nvim ---
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
