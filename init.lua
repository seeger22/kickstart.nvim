-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Skips default Netrw, use oil instead
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Disable built-in zip plugin so it doesn't hijack .xlsx (which is a zip archive);
-- visidata handles them via the BufReadCmd in lua/config/autocmds.lua.
vim.g.loaded_zipPlugin = 1
vim.g.loaded_zip = 1

-- Everything else lives in lua/: config/ for options, keymaps and autocmds,
-- plugins/ for lazy.nvim specs (one file per feature).
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.images'
require 'config.private'
require 'config.lazy'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
