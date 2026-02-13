-- User autocmds loaded by LazyVim.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.nix",
  callback = function() vim.b.cafaye_last_nix_write = os.time() end,
})
