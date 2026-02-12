-- ~/.config/cafaye/config/user/nvim/lua/user/plugins.lua
-- ═══════════════════════════════════════════════════════════════════
-- Your Neovim Plugins
-- ═══════════════════════════════════════════════════════════════════
--
-- Add or override plugins for AstroNvim.
-- Each plugin is a table returned in the array.
--
-- Documentation: https://docs.astronvim.com/recipes/custom_plugins/
-- ═══════════════════════════════════════════════════════════════════

-- AstroNvim uses lazy.nvim for plugin management.
-- Plugins are loaded lazily for better performance.

---@type LazySpec
return {
  -- ═══════════════════════════════════════════════════════════════════
  -- ADDING NEW PLUGINS
  -- ═══════════════════════════════════════════════════════════════════
  -- Example: Add a new plugin (no configuration)
  -- "andweeb/presence.nvim",

  -- Example: Add a plugin with configuration
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },

  -- ═══════════════════════════════════════════════════════════════════
  -- DISABLING DEFAULT PLUGINS
  -- ═══════════════════════════════════════════════════════════════════
  -- Disable plugins you don't want:

  -- { "max397574/better-escape.nvim", enabled = false },
  -- { "akinsho/toggleterm.nvim", enabled = false },

  -- ═══════════════════════════════════════════════════════════════════
  -- CUSTOMIZING EXISTING PLUGINS
  -- ═══════════════════════════════════════════════════════════════════
  -- Override default plugin settings:

  -- Example: Customize LuaSnip
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     -- Include default AstroNvim config
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts)
  --     
  --     -- Add your custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --     luasnip.filetype_extend("ruby", { "rails" })
  --   end,
  -- },

  -- Example: Customize Treesitter
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     -- Add more languages
  --     vim.list_extend(opts.ensure_installed, {
  --       "ruby",
  --       "python",
  --       "go",
  --     })
  --   end,
  -- },

  -- Example: Customize Telescope
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   opts = {
  --     defaults = {
  --       layout_strategy = "horizontal",
  --       layout_config = {
  --         horizontal = {
  --           preview_width = 0.6,
  --         },
  --       },
  --     },
  --   },
  -- },

  -- ═══════════════════════════════════════════════════════════════════
  -- LANGUAGE-SPECIFIC PLUGINS
  -- ═══════════════════════════════════════════════════════════════════

  -- Ruby/Rails development
  -- {
  --   "tpope/vim-rails",
  --   ft = "ruby",
  -- },

  -- Python development
  -- {
  --   "psf/black",
  --   ft = "python",
  --   config = function()
  --     vim.keymap.set("n", "<leader>bf", ":Black<CR>", { desc = "Format with Black" })
  --   end,
  -- },

  -- Go development
  -- {
  --   "fatih/vim-go",
  --   ft = "go",
  -- },

  -- ═══════════════════════════════════════════════════════════════════
  -- PRODUCTIVITY PLUGINS
  -- ═══════════════════════════════════════════════════════════════════

  -- Session management (saves your open files/layouts)
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false,
  --   config = function()
  --     require("auto-session").setup {
  --       log_level = "error",
  --       auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
  --     }
  --   end,
  -- },

  -- Better folding
  -- {
  --   "kevinhwang91/nvim-ufo",
  --   dependencies = "kevinhwang91/promise-async",
  --   event = "BufRead",
  --   config = function()
  --     require("ufo").setup()
  --   end,
  -- },

  -- Smooth scrolling
  -- {
  --   "karb94/neoscroll.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("neoscroll").setup()
  --   end,
  -- },

  -- ═══════════════════════════════════════════════════════════════════
  -- APPEARANCE PLUGINS
  -- ═══════════════════════════════════════════════════════════════════

  -- Alternative themes (uncomment to use instead of Catppuccin)
  -- { "folke/tokyonight.nvim" },
  -- { "ellisonleao/gruvbox.nvim" },
  -- { "rebelot/kanagawa.nvim" },

  -- Status line customization
  -- {
  --   "rebelot/heirline.nvim",
  --   opts = function(_, opts)
  --     -- Customize status line
  --     local status = require("astronvim.utils.status")
  --     opts.statusline = {
  --       hl = { fg = "fg", bg = "bg" },
  --       status.component.mode(),
  --       status.component.git_branch(),
  --       status.component.file_info(),
  --       status.component.git_diff(),
  --       status.component.diagnostics(),
  --       status.component.fill(),
  --       status.component.cmd_info(),
  --       status.component.fill(),
  --       status.component.lsp(),
  --       status.component.treesitter(),
  --       status.component.nav(),
  --       status.component.mode({ surround = { separator = "right" } }),
  --     }
  --   end,
  -- },

  -- ═══════════════════════════════════════════════════════════════════
  -- YOUR CUSTOM PLUGINS BELOW
  -- ═══════════════════════════════════════════════════════════════════

}
