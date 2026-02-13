# Customization Guide

This guide explains how to customize Cafaye OS while maintaining clean separation between system defaults and your personal preferences.

## Philosophy: Layered Configuration

Cafaye uses a **layered approach**:

1. **Cafaye Defaults** (`config/cafaye/`) - System-provided, updated via `caf update`
2. **User Overrides** (`config/user/`) - Your customizations, never overwritten
3. **Local State** (`environment.json`, `settings.json`) - Machine-specific choices

**Golden Rule**: Only edit files in `config/user/` and the JSON state files.

## Directory Structure

```
~/.config/cafaye/
├── environment.json          # ✏️ EDIT: Languages, frameworks, editor
├── settings.json             # ✏️ EDIT: Git, backup, VPS settings
├── config/
│   ├── cafaye/              # ❌ DON'T EDIT: System defaults
│   │   ├── zsh/
│   │   ├── tmux/
│   │   ├── nvim/
│   │   └── bin/
│   └── user/                # ✅ EDIT: Your customizations
│       ├── zsh/
│       │   └── custom.zsh
│       ├── tmux/
│       │   ├── workspace.yml
│       │   └── tmux.conf
│       └── nvim/
│           └── astronvim/
└── secrets/                 # 🔐 ENCRYPTED: Fleet, API keys
    └── fleet.yaml
```

## Common Customizations

### 1. Shell Aliases and Functions

**File**: `~/.config/cafaye/config/user/zsh/custom.zsh`

```bash
# Custom aliases
alias gs='git status'
alias gp='git push'
alias dc='docker-compose'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Environment variables
export EDITOR=nvim
export PAGER=less

# Project-specific paths
export PATH="$HOME/my-project/bin:$PATH"
```

**Apply changes**:
```bash
source ~/.zshrc
# or restart your shell
```

### 2. Tmux Workspace

**File**: `~/.config/cafaye/config/user/tmux/workspace.yml`

```yaml
session: cafaye
start_window: terminal

windows:
  - name: dashboard
    command: caf-dashboard
  
  - name: terminal
    command: cd ~/projects
  
  - name: editor
    command: cd ~/projects && nvim
  
  - name: git
    command: lazygit
  
  - name: api
    command: cd ~/api && npm run dev
  
  - name: logs
    command: tail -f /var/log/app.log
```

**Preview**:
```bash
caf-workspace-run --dry-run
```

**Apply**:
```bash
caf-workspace-init --attach
```

### 3. Tmux Keybindings

**File**: `~/.config/cafaye/config/user/tmux/tmux.conf`

```tmux
# Custom prefix (default is Ctrl+Space)
# unbind C-Space
# set -g prefix C-a
# bind C-a send-prefix

# Quick window switching
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3

# Split panes with | and -
bind | split-window -h
bind - split-window -v

# Resize panes with vim keys
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

### 4. Editor (Neovim/AstroNvim)

**Directory**: `~/.config/cafaye/config/user/nvim/astronvim/`

**Custom plugins** (`plugins/user.lua`):
```lua
return {
  -- Add your custom plugins
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "github/copilot.vim",
    event = "VeryLazy",
  },
}
```

**Custom mappings** (`mappings.lua`):
```lua
return {
  n = {
    -- Custom normal mode mappings
    ["<leader>gg"] = { "<cmd>LazyGit<cr>", desc = "LazyGit" },
    ["<leader>tt"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
  },
  i = {
    -- Custom insert mode mappings
    ["jk"] = { "<Esc>", desc = "Exit insert mode" },
  },
}
```

**Custom options** (`init.lua`):
```lua
return {
  opt = {
    relativenumber = true,
    wrap = true,
    spell = false,
    colorcolumn = "80",
  },
}
```

### 5. Adding Languages and Frameworks

**File**: `~/.config/cafaye/environment.json`

```json
{
  "languages": {
    "python": true,
    "nodejs": true,
    "go": true,
    "rust": true
  },
  "frameworks": {
    "rails": true,
    "django": false,
    "nextjs": true
  },
  "services": {
    "docker": true,
    "postgresql": true,
    "redis": true
  }
}
```

**Apply**:
```bash
caf apply
```

### 6. Git Configuration

**File**: `~/.config/cafaye/settings.json`

```json
{
  "git": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "backup": {
    "type": "GitHub (recommended)",
    "url": "https://github.com/yourusername/cafaye",
    "strategy": "Push daily (recommended)"
  }
}
```

### 7. Shell Leader Key

**File**: `~/.config/cafaye/config/user/zsh/custom.zsh`

```bash
# Change leader key from Space to Comma
export CAFAYE_LEADER_KEY="comma"

# Adjust timeouts (in milliseconds)
export CAFAYE_LEADER_TIMEOUT_MS=700
export CAFAYE_DOUBLE_TAP_MS=400

# Disable auto-tmux attachment
export CAFAYE_AUTO_TMUX=0

# Disable auto-status on shell startup
# (Set via: caf-state-write core.autostatus false)
```

### 8. Theme and Colors

**File**: `~/.config/cafaye/environment.json`

```json
{
  "interface": {
    "theme": "catppuccin mocha",
    "terminal": {
      "shell": "zsh"
    }
  }
}
```

**Available themes**:
- `catppuccin mocha`
- `tokyo night`
- `gruvbox`

**Apply**:
```bash
caf apply
```

### 9. Secrets Management

**Add a secret**:
```bash
caf-secrets
# Choose: Add/Update Secret
# Enter key: openai_api_key
# Enter value: sk-...
```

**Use in scripts**:
```bash
# Decrypt and read
API_KEY=$(sops -d ~/.config/cafaye/secrets/fleet.yaml | yq .openai_api_key)
```

**Edit secrets file directly**:
```bash
sops ~/.config/cafaye/secrets/fleet.yaml
```

### 10. Custom Scripts and Utilities

**Directory**: `~/.config/cafaye/config/user/bin/`

Create executable scripts here and they'll be in your PATH:

```bash
#!/bin/bash
# ~/.config/cafaye/config/user/bin/my-deploy

set -euo pipefail
echo "Deploying to production..."
git push production main
```

Make it executable:
```bash
chmod +x ~/.config/cafaye/config/user/bin/my-deploy
```

Use it:
```bash
my-deploy
```

## Advanced Customizations

### Custom Nix Packages

**File**: `~/.config/cafaye/config/user/packages.nix`

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Add custom packages
    bat
    exa
    ripgrep
    fd
    httpie
  ];
}
```

### Environment Variables

**File**: `~/.config/cafaye/config/user/zsh/custom.zsh`

```bash
# Development
export NODE_ENV=development
export RAILS_ENV=development

# API Keys (use secrets for sensitive data!)
export GITHUB_TOKEN=$(sops -d ~/.config/cafaye/secrets/fleet.yaml | yq .github_token)

# Paths
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"

# Tool configuration
export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
export BAT_THEME="Catppuccin-mocha"
```

### Custom Workspace Layouts

**Multiple workspaces**:

```bash
# Create project-specific workspace
cp ~/.config/cafaye/config/user/tmux/workspace.yml \
   ~/.config/cafaye/config/user/tmux/workspace-myproject.yml

# Edit it
vim ~/.config/cafaye/config/user/tmux/workspace-myproject.yml

# Use it
CAFAYE_WORKSPACE=myproject caf-workspace-init --attach
```

## Best Practices

### ✅ DO

- **Keep user customizations in `config/user/`**
- **Use `environment.json` for declarative choices**
- **Store secrets in SOPS-encrypted files**
- **Test changes with `caf apply --dry-run`** (if available)
- **Commit your `config/user/` to version control**
- **Document your customizations**

### ❌ DON'T

- **Don't edit files in `config/cafaye/`** (they'll be overwritten)
- **Don't commit secrets to Git** (use SOPS)
- **Don't hardcode paths** (use `$HOME`, `$CAFAYE_DIR`)
- **Don't skip `caf apply`** after changes
- **Don't modify `local-user.nix`** directly (regenerated)

## Syncing Customizations

### To a New Machine

```bash
# On new machine, after install
cd ~/.config/cafaye
git remote add origin https://github.com/yourusername/cafaye.git
git pull origin master

# Apply
caf apply
```

### Across Fleet

```bash
# Sync to all nodes
caf fleet sync

# Apply on all nodes
caf fleet apply
```

## Troubleshooting

### Changes Not Applied

```bash
# Rebuild
caf apply

# Check for errors
caf-system-doctor

# View logs
cat ~/.config/cafaye/logs/rebuild.log
```

### Conflicts with Defaults

If your customizations conflict with system defaults:

1. Check `config/cafaye/` for the default
2. Override in `config/user/` with higher specificity
3. Use `lib.mkForce` in Nix if needed (advanced)

### Reset to Defaults

```bash
# Remove user customizations
rm -rf ~/.config/cafaye/config/user/*

# Rebuild
caf apply
```

## Examples

### Example 1: Rails Developer Setup

```json
// environment.json
{
  "languages": {
    "ruby": true,
    "nodejs": true
  },
  "frameworks": {
    "rails": true
  },
  "services": {
    "postgresql": true,
    "redis": true,
    "docker": true
  }
}
```

```bash
# custom.zsh
alias rs='rails server'
alias rc='rails console'
alias rr='rails routes'
alias be='bundle exec'

export EDITOR=nvim
```

### Example 2: Go Developer Setup

```json
// environment.json
{
  "languages": {
    "go": true
  }
}
```

```bash
# custom.zsh
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"

alias got='go test ./...'
alias gob='go build'
alias gor='go run'
```

### Example 3: Multi-Project Workspace

```yaml
# workspace-fullstack.yml
session: fullstack
start_window: api

windows:
  - name: api
    command: cd ~/projects/api && npm run dev
  
  - name: web
    command: cd ~/projects/web && npm run dev
  
  - name: db
    command: docker-compose up postgres redis
  
  - name: editor
    command: cd ~/projects && nvim
  
  - name: git
    command: lazygit
```

---

**Need more help?** Check `docs/GETTING-STARTED.md` or run `caf-hints`.
