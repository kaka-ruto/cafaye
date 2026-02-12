return {
  dir = "~/Code/lua/notre.nvim", -- Path to your local clone
  name = "notre.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("notre").setup {
      -- your configuration
    }
  end,
}
