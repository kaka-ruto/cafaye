-- ~/.config/cafaye/config/user/nvim/lua/user/polish.lua
-- ═══════════════════════════════════════════════════════════════════
-- Your Final Polish Configuration
-- ═══════════════════════════════════════════════════════════════════
--
-- This file runs LAST in the AstroNvim setup process.
-- Use it for anything that doesn't fit in the other config files.
-- Perfect for running Lua code that sets up your specific workflow.
--
-- Documentation: https://docs.astronvim.com/
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- AUTOCOMMANDS
-- ═══════════════════════════════════════════════════════════════════
-- Run commands on specific events

-- Example: Highlight on yank
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   desc = "Highlight when yanking (copying) text",
--   group = vim.api.nvim_create_augroup("user-highlight-yank", { clear = true }),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })

-- Example: Auto-resize splits when window is resized
-- vim.api.nvim_create_autocmd("VimResized", {
--   pattern = "*",
--   command = "wincmd =",
-- })

-- Example: Set specific options for specific file types
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "ruby", "eruby" },
--   callback = function()
--     vim.opt_local.shiftwidth = 2
--     vim.opt_local.tabstop = 2
--   end,
-- })

-- Example: Open help in vertical split
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "help",
--   callback = function()
--     vim.cmd.wincmd("L")
--     vim.cmd.vertical("resize 80")
--   end,
-- })

-- ═══════════════════════════════════════════════════════════════════
-- USER COMMANDS
-- ═══════════════════════════════════════════════════════════════════
-- Create custom commands

-- Example: Command to open current file in GitHub
-- vim.api.nvim_create_user_command("Browse", function()
--   vim.fn.system("gh browse " .. vim.fn.expand("%:p"))
-- end, {})

-- Example: Command to copy current file path
-- vim.api.nvim_create_user_command("CopyPath", function()
--   vim.fn.setreg("+", vim.fn.expand("%:p"))
--   print("Copied: " .. vim.fn.expand("%:p"))
-- end, {})

-- ═══════════════════════════════════════════════════════════════════
-- CUSTOM FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════
-- Define helper functions

-- Example: Toggle diagnostics visibility
-- local diagnostics_active = true
-- function _G.toggle_diagnostics()
--   diagnostics_active = not diagnostics_active
--   if diagnostics_active then
--     vim.diagnostic.show()
--   else
--     vim.diagnostic.hide()
--   end
-- end
-- vim.keymap.set("n", "<leader>td", toggle_diagnostics, { desc = "Toggle diagnostics" })

-- Example: Better fold text
-- function _G.custom_foldtext()
--   local line = vim.fn.getline(vim.v.foldstart)
--   local line_count = vim.v.foldend - vim.v.foldstart + 1
--   return line .. " ... " .. line_count .. " lines"
-- end
-- vim.opt.foldtext = "v:lua.custom_foldtext()"

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE TWEAKS
-- ═══════════════════════════════════════════════════════════════════

-- Disable unused providers for faster startup
-- vim.g.loaded_python3_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_node_provider = 0

-- ═══════════════════════════════════════════════════════════════════
-- YOUR CUSTOMIZATIONS BELOW
-- ═══════════════════════════════════════════════════════════════════

