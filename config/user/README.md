# Customizing Your Cafaye Environment

This guide explains how to customize every aspect of your Cafaye development environment.

## 📁 Where to Customize

**All your customizations live in:**
```
~/.config/cafaye/config/user/
```

**Never edit:** `~/.config/cafaye/config/cafaye/` (Cafaye-managed defaults)

## 🎯 Quick Start

### 1. Find What You Want to Customize

Run `caf` → "⚙️  Configure" to see all customizable options, or edit files directly in:

```bash
~/.config/cafaye/config/user/
├── tmux/                     # Terminal multiplexer
├── ghostty/                  # Terminal emulator  
├── lazygit/                  # Git UI
├── nvim/                     # Neovim editors
│   ├── astronvim/           # If using AstroNvim
│   ├── lazyvim/             # If using LazyVim
│   └── nvchad/              # If using NvChad
├── zsh/                      # Shell customizations
└── README.md                 # This file
```

### 2. Edit the File

Each file has extensive comments showing examples:

```bash
# Example: Customize tmux prefix key
vim ~/.config/cafaye/config/user/tmux/tmux.conf

# Uncomment and modify:
set -g prefix `
bind ` send-prefix
```

### 3. Apply Changes

Most changes apply immediately. Some need a reload:

```bash
caf tmux reload        # Reload tmux
caf zsh reload         # Reload zsh
# nvim changes apply on restart
```

### 4. Save to Git

```bash
caf sync push
# Or manually:
git add ~/.config/cafaye/config/user/
git commit -m "Customize tmux prefix"
git push
```

## 🛠️ Tool-by-Tool Customization

---

### Terminal: Ghostty

**File:** `config/user/ghostty/config`

**Common customizations:**
```ini
# Font
font-family = "FiraCode Nerd Font"
font-size = 16

# Theme
theme = tokyo-night

# Window
window-padding-x = 20
window-padding-y = 20

# Cursor
cursor-style = bar
cursor-blink = true
```

**Documentation:** https://ghostty.org/docs/config

**Reload:** Exit and reopen Ghostty

---

### Terminal Multiplexer: tmux

**Main config:** `config/user/tmux/tmux.conf`

**Common customizations:**
```bash
# Change prefix from Ctrl+A to backtick
set -g prefix `
bind ` send-prefix
unbind C-a

# Add plugins
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
```

**Layouts:** `config/user/tmux/layouts/`

Create project-specific layouts:
```yaml
# config/user/tmux/layouts/my-project.yml
name: my-project
root: ~/Code/projects/my-project
windows:
  - editor:
      panes:
        - nvim
  - server:
      panes:
        - rails server
  - logs:
      panes:
        - tail -f log/development.log
```

Load it:
```bash
caf tmux layout my-project
```

**Documentation:** https://github.com/tmux/tmux/wiki

**Reload:** `caf tmux reload` or `tmux source-file ~/.config/tmux/tmux.conf`

---

### Git UI: lazygit

**File:** `config/user/lazygit/config.yml`

**Common customizations:**
```yaml
# Custom commands
customCommands:
  - key: "<c-p>"
    description: "Create PR on GitHub"
    command: "gh pr create --fill --web"
    context: "localBranches"
    
  - key: "<c-b>"
    description: "Checkout PR by number"
    prompts:
      - type: "input"
        title: "PR number:"
    command: "gh pr checkout {{index .PromptResponses 0}}"
    context: "localBranches"
```

**Documentation:** https://github.com/jesseduffield/lazygit

**Reload:** Exit and reopen lazygit

---

### Editor: Neovim

Cafaye supports three Neovim distributions. Your customizations go in different places depending on which one you use.

**Check which one you're using:**
```bash
cat ~/.config/nvim/.cafaye-distro
# Outputs: astronvim, lazyvim, or nvchad
```

#### AstroNvim

**Location:** `config/user/nvim/astronvim/`

**Files:**
- `plugins.lua` - Add/override plugins
- `mappings.lua` - Custom keybindings
- `highlights.lua` - Color customizations
- `polish.lua` - Final tweaks

**Example - Add a plugin:**
```lua
-- config/user/nvim/astronvim/plugins.lua
return {
  "tpope/vim-rails",
  ft = "ruby",
}
```

**Example - Custom keybinding:**
```lua
-- config/user/nvim/astronvim/mappings.lua
return {
  n = {
    ["<C-s>"] = { ":w<cr>", desc = "Save file" },
  }
}
```

**Documentation:** https://docs.astronvim.com/

---

#### LazyVim

**Location:** `config/user/nvim/lazyvim/`

**Files:**
- `options.lua` - Vim options
- `keymaps.lua` - Key mappings
- `autocmds.lua` - Autocommands
- `plugins/` - Plugin specifications (any .lua file)

**Example - Change theme:**
```lua
-- config/user/nvim/lazyvim/plugins/colorscheme.lua
return {
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
```

**Documentation:** https://www.lazyvim.org/configuration

---

#### NvChad

**Location:** `config/user/nvim/nvchad/`

**Files:**
- `chadrc.lua` - UI and theme config
- `mappings.lua` - Key mappings
- `options.lua` - Vim options
- `plugins.lua` - Plugin specifications
- `configs/` - Plugin-specific configs

**Example - Change theme:**
```lua
-- config/user/nvim/nvchad/chadrc.lua
local M = {}

M.ui = {
  theme = "catppuccin",
  transparency = false,
}

return M
```

**Documentation:** https://nvchad.com/docs/config/walkthrough

---

### Shell: Zsh

**File:** `config/user/zsh/custom.zsh`

**Common customizations:**
```bash
# Aliases
alias g='git'
alias d='docker'
alias t='tmux'

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Environment
export EDITOR='nvim'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'
```

**Reload:** `caf zsh reload` or `source ~/.zshrc`

---

## 🎨 Themes

### Terminal Theme (Ghostty)

Edit `config/user/ghostty/config`:
```ini
theme = catppuccin-mocha
# Options: catppuccin-mocha, catppuccin-latte, tokyo-night, gruvbox
```

### tmux Theme

Edit `config/user/tmux/tmux.conf`:
```bash
# Status bar colors
set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
set -g window-status-current-style "bg=#89b4fa,fg=#1e1e2e"
```

### Editor Theme

**AstroNvim:**
```lua
-- config/user/nvim/astronvim/polish.lua
vim.cmd.colorscheme("tokyonight")
```

**LazyVim:**
```lua
-- config/user/nvim/lazyvim/plugins/colorscheme.lua
return {
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } }
}
```

**NvChad:**
```lua
-- config/user/nvim/nvchad/chadrc.lua
local M = {}
M.ui = { theme = "tokyonight" }
return M
```

---

## 🔄 Saving & Syncing

### Save Your Changes

```bash
# See what changed
git -C ~/.config/cafaye status

# Commit and push
caf sync push
```

### Sync to Another Machine

On a new machine:
```bash
# Install Cafaye
curl -fsSL https://cafaye.com/install.sh | bash

# Pull your customizations
caf sync pull

# Your exact setup is restored!
```

---

## 🆘 Troubleshooting

### Changes not applying?

- **tmux:** Run `caf tmux reload`
- **zsh:** Run `caf zsh reload`
- **nvim:** Restart nvim
- **ghostty:** Exit and reopen

### Check your config

```bash
# Validate tmux config
tmux -f ~/.config/tmux/tmux.conf source-file

# Check nvim config
nvim --headless -c 'quitall' 2>&1

# Test lazygit config
lazygit --debug
```

### Reset to defaults

```bash
# Reset specific tool to Cafaye defaults
caf config reset tmux
caf config reset ghostty
caf config reset nvim
```

---

## 📚 Resources

- **tmux:** https://github.com/tmux/tmux/wiki
- **Ghostty:** https://ghostty.org/docs/config
- **lazygit:** https://github.com/jesseduffield/lazygit
- **AstroNvim:** https://docs.astronvim.com/
- **LazyVim:** https://www.lazyvim.org/
- **NvChad:** https://nvchad.com/docs/
- **Zsh:** https://zsh.sourceforge.io/Doc/

---

## 💡 Tips

1. **Start small** - Only customize what bothers you
2. **Copy from examples** - Every file has commented examples
3. **Test incrementally** - Make one change, test, then commit
4. **Use layouts** - Create tmux layouts for different project types
5. **Keep it in git** - Always push your changes
6. **Read the comments** - Every config file has extensive documentation

---

**Remember:** You only need to edit files in `~/.config/cafaye/config/user/`. Never edit files in `~/.config/cafaye/config/cafaye/` - those are managed by Cafaye and will be overwritten on updates!
