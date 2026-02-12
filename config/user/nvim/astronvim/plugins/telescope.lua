return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local mappings = require("astrocore").empty_map_table()

    mappings.n["<Leader>fe"] = {
      function()
        vim.ui.input({
          prompt = "Glob pattern (e.g., *.md, *.{rb,erb}, **/*.lua): ",
          default = "*.",
        }, function(pattern)
          if pattern and pattern ~= "" then
            require("telescope.builtin").live_grep {
              prompt_title = "Search in " .. pattern,
              glob_pattern = pattern,
            }
          end
        end)
      end,
      desc = "Find words with custom glob pattern",
    }

    require("astrocore").set_mappings(mappings)
  end,
}
