-- AstroNvim Starter Configuration for Cafaye OS
-- Catppuccin-themed AstroNvim setup

return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin",
    channel = "stable",
    version = "latest",
    branch = "nightly",
    commit = nil,
    pin_plugins = nil,
    skip_prompts = false,
    show_changelog = true,
    auto_quit = false,
  },

  -- Set colorscheme to catppuccin
  colorscheme = "catppuccin-mocha",

  -- Diagnostics configuration
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {},
        ignore_filetypes = {},
      },
    },
  },

  -- Configure plugins
  plugins = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavour = "mocha",
      },
    },
  },

  -- Polish
  polish = function()
    vim.opt.relativenumber = true
    vim.opt.clipboard = "unnamedplus"
  end,
}
