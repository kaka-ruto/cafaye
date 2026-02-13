return {
  "kaka-ruto/notre.nvim",
  name = "notre.nvim", -- Falls back to GitHub so VPS installs don't break
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("notre").setup {
      -- your configuration
    }
  end,
}
