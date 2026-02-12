-- ~/.config/cafaye/config/user/nvim/lua/user/init.lua
-- ═══════════════════════════════════════════════════════════════════
-- Your Neovim/AstroNvim Configuration
-- ═══════════════════════════════════════════════════════════════════
--
-- This file customizes AstroNvim (Cafaye's default Neovim setup).
-- AstroNvim uses lazy.nvim for plugin management.
--
-- Quick Reference:
--   Space + e    : Toggle file explorer
--   Space + ff   : Find files
--   Space + fg   : Live grep
--   Space + n    : New file
--   Space + c    : Close buffer
--
-- Documentation: https://docs.astronvim.com/
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- OPTIONS
-- ═══════════════════════════════════════════════════════════════════
-- Override default options:

local options = {
  opt = {
    -- Tab settings
    -- tabstop = 2,
    -- shiftwidth = 2,
    -- expandtab = true,
    
    -- Line numbers
    -- relativenumber = true,
    -- number = true,
    
    -- Wrap settings
    -- wrap = false,
    
    -- Clipboard
    -- clipboard = "unnamedplus",
    
    -- Search
    -- ignorecase = true,
    -- smartcase = true,
  },
  g = {
    -- Leader key (Space is default, don't change unless you know why)
    -- mapleader = " ",
    
    -- Disable animations
    -- animations = false,
  }
}

-- Apply options
-- for scope, table in pairs(options) do
--   for setting, value in pairs(table) do
--     vim[scope][setting] = value
--   end
-- end

-- ═══════════════════════════════════════════════════════════════════
-- KEYMAPS
-- ═══════════════════════════════════════════════════════════════════
-- Add custom keybindings:

-- Save with Ctrl+S
-- vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })

-- Close buffer with Ctrl+Q
-- vim.keymap.set("n", "<C-q>", ":q<CR>", { desc = "Quit" })

-- Better window navigation
-- vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
-- vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
-- vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
-- vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ═══════════════════════════════════════════════════════════════════
-- AUTOCOMMANDS
-- ═══════════════════════════════════════════════════════════════════
-- Run commands on specific events:

-- Highlight yanked text
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   desc = "Highlight when yanking (copying) text",
--   group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })

-- Auto-resize splits when window is resized
-- vim.api.nvim_create_autocmd("VimResized", {
--   pattern = "*",
--   command = "wincmd =",
-- })

-- ═══════════════════════════════════════════════════════════════════
-- COLORS & THEME
-- ═══════════════════════════════════════════════════════════════════
-- Cafaye default: Catppuccin. Change if desired:

-- vim.cmd.colorscheme("tokyonight")
-- OR
-- vim.cmd.colorscheme("gruvbox")

-- ═══════════════════════════════════════════════════════════════════
-- DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════════
-- Configure LSP diagnostics display:

-- vim.diagnostic.config({
--   virtual_text = true,
--   signs = true,
--   underline = true,
--   update_in_insert = false,
--   severity_sort = true,
-- })

-- ═══════════════════════════════════════════════════════════════════
-- YOUR CUSTOMIZATIONS BELOW
-- ═══════════════════════════════════════════════════════════════════

