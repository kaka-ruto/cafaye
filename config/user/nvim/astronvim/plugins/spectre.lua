return {
  "nvim-pack/nvim-spectre",
  config = function()
    require("spectre").setup {
      mapping = {
        ["run_replace"] = {
          map = "<leader>sr",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["resume_last_search"] = {
          map = "<leader>sl",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "repeat last search",
        },
      },
    }
  end,
}
