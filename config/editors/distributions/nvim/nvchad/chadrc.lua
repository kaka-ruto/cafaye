-- NvChad Starter Configuration for Cafaye OS
-- Catppuccin-themed NvChad setup

-- This file would be placed at ~/.config/nvim/lua/chadrc.lua
-- After cloning NvChad starter

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "one_light" },

  transparency = false,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.plugins = "plugins"

M.mappings = require "mappings"

return M
