-- LunarVim Starter Configuration for Cafaye OS
-- config.lua for LunarVim

-- General options
lvim.log.level = "warn"
lvim.format_on_save.enabled = true
lvim.colorscheme = "catppuccin-mocha"

-- Leader key
lvim.leader = "space"

-- Keymappings
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

-- Use built-in catppuccin if installed via plugin
lvim.plugins = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
    end,
  },
}

-- Treesitter settings
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "ruby",
  "yaml",
  "nix",
}

lvim.builtin.treesitter.highlight.enable = true

-- Additional UI options
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
