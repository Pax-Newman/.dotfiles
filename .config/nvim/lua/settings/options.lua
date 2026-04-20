-- [[ Setting options ]]
-- See `:help opt`
-- For more options, you can see `:help option-list`

local opt = vim.opt
local g = vim.g

-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
g.mapleader = " "
g.maplocalleader = " "

g.have_nerd_font = true

-- Enable true colors
opt.termguicolors = true

-- Ignore case in search
opt.ignorecase = true

-- Show line numbers
opt.number = true

-- Show whitespace characters
opt.list = true

-- Enable mouse mode, can be useful for resizing splits for example
opt.mouse = "a"

-- Make line numbers default
opt.number = true
-- You can also add relative line numbers, for help with jumping.
-- opt.relativenumber = true

vim.cmd.filetype "plugin indent on" -- Enable filetype detection, plugins, and indentation

-- Don't show the mode, since it's already in status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = "unnamedplus"

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Add rounded borders to diagnostic windows
vim.diagnostic.config { float = { border = "rounded" }, underline = true }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- Set tab width
opt.tabstop = 4

-- Point nvim to the virtualenv
g.python3_host_prog = vim.fn.expand "~/.config/nvim/venv/bin/python3"
