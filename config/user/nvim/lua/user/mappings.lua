-- ~/.config/cafaye/config/user/nvim/lua/user/mappings.lua
-- ═══════════════════════════════════════════════════════════════════
-- Your Custom Key Mappings
-- ═══════════════════════════════════════════════════════════════════
--
-- Add or override key mappings for AstroNvim.
-- AstroNvim uses which-key for discoverable keybindings.
--
-- Documentation: https://docs.astronvim.com/recipes/mappings/
-- ═══════════════════════════════════════════════════════════════════

-- Mapping tables
local mappings = {
  -- ═══════════════════════════════════════════════════════════════════
  -- NORMAL MODE MAPPINGS (n)
  -- ═══════════════════════════════════════════════════════════════════
  n = {
    -- Second key is the command, third is description (for which-key)
    
    -- Quick save
    -- ["<C-s>"] = { ":w<cr>", desc = "Save file" },
    
    -- Quick quit
    -- ["<C-q>"] = { ":q<cr>", desc = "Quit" },
    
    -- Better window navigation
    -- ["<C-h>"] = { "<C-w>h", desc = "Go to left window" },
    -- ["<C-j>"] = { "<C-w>j", desc = "Go to lower window" },
    -- ["<C-k>"] = { "<C-w>k", desc = "Go to upper window" },
    -- ["<C-l>"] = { "<C-w>l", desc = "Go to right window" },
    
    -- Resize windows
    -- ["<C-Up>"] = { ":resize -2<CR>", desc = "Decrease window height" },
    -- ["<C-Down>"] = { ":resize +2<CR>", desc = "Increase window height" },
    -- ["<C-Left>"] = { ":vertical resize -2<CR>", desc = "Decrease window width" },
    -- ["<C-Right>"] = { ":vertical resize +2<CR>", desc = "Increase window width" },
    
    -- Buffers
    -- ["<S-l>"] = { ":bnext<CR>", desc = "Next buffer" },
    -- ["<S-h>"] = { ":bprevious<CR>", desc = "Previous buffer" },
    -- ["<leader>bd"] = { ":bdelete<CR>", desc = "Close buffer" },
    
    -- Stay in indent mode
    -- ["<"] = { "<gv", desc = "Indent left and reselect" },
    -- [">"] = { ">gv", desc = "Indent right and reselect" },
    
    -- Move text up and down
    -- ["<A-j>"] = { ":m .+1<CR>==", desc = "Move line down" },
    -- ["<A-k>"] = { ":m .-2<CR>==", desc = "Move line up" },
    
    -- Quickfix navigation
    -- ["]q"] = { ":cnext<CR>", desc = "Next quickfix item" },
    -- ["[q"] = { ":cprev<CR>", desc = "Previous quickfix item" },
  },
  
  -- ═══════════════════════════════════════════════════════════════════
  -- INSERT MODE MAPPINGS (i)
  -- ═══════════════════════════════════════════════════════════════════
  i = {
    -- Quick escape
    -- ["jk"] = { "<ESC>", desc = "Escape" },
    -- ["jj"] = { "<ESC>", desc = "Escape" },
    
    -- Move line in insert mode
    -- ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", desc = "Move line down" },
    -- ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", desc = "Move line up" },
  },
  
  -- ═══════════════════════════════════════════════════════════════════
  -- VISUAL MODE MAPPINGS (v)
  -- ═══════════════════════════════════════════════════════════════════
  v = {
    -- Better paste (don't replace clipboard)
    -- ["p"] = { '"_dP', desc = "Paste without replacing clipboard" },
    
    -- Stay in indent mode
    -- ["<"] = { "<gv", desc = "Indent left and reselect" },
    -- [">"] = { ">gv", desc = "Indent right and reselect" },
    
    -- Move text up and down
    -- ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
    -- ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
  },
  
  -- ═══════════════════════════════════════════════════════════════════
  -- VISUAL BLOCK MODE MAPPINGS (x)
  -- ═══════════════════════════════════════════════════════════════════
  x = {
    -- Move text up and down
    -- ["<A-j>"] = { ":m '>+1<CR>gv-gv", desc = "Move selection down" },
    -- ["<A-k>"] = { ":m '<-2<CR>gv-gv", desc = "Move selection up" },
  },
  
  -- ═══════════════════════════════════════════════════════════════════
  -- TERMINAL MODE MAPPINGS (t)
  -- ═══════════════════════════════════════════════════════════════════
  t = {
    -- Easy escape from terminal
    -- ["<esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
    -- ["jk"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
  },
}

-- Apply mappings
-- return mappings

-- Return empty to use AstroNvim defaults
return {}
