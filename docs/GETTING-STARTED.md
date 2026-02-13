# Getting Started with Cafaye OS

**Cafaye** is a distributed development infrastructure that gives you a reproducible, Nix-powered environment across all your machines—from your laptop to remote VPS nodes.

## Quick Start (5 minutes)

### Prerequisites

- **macOS** (10.15+) or **Linux** (Ubuntu 20.04+, Debian 11+)
- **2GB RAM** minimum (4GB+ recommended)
- **10GB free disk space**
- **Internet connection**

### Installation

```bash
# Clone and run the installer
git clone https://github.com/cafaye/cafaye.git
cd cafaye
./install.sh
```

The installer will guide you through:
1. **Git Identity** - Your name and email for commits
2. **Backup Strategy** - Where to sync your config (GitHub recommended)
3. **Editor** - Choose Neovim, Helix, or VS Code Server
4. **Theme** - Pick your color scheme
5. **Tailscale** (optional) - Secure networking for distributed fleet
6. **VPS Options** (Linux only) - SSH key import and auto-shutdown

### First Steps After Install

```bash
# Open the main menu
caf

# Check system status
caf status

# Install a language stack (e.g., Ruby on Rails)
caf install rails

# Apply changes
caf apply
```

## Core Concepts

### 1. **Declarative Configuration**
Your entire environment is defined in `~/.config/cafaye/`:
- `environment.json` - Languages, frameworks, editor choices
- `settings.json` - Git config, backup settings, VPS options
- `config/user/` - Your personal customizations

### 2. **Reproducibility**
Everything is managed by Nix and Home Manager:
```bash
# Rebuild from scratch
caf apply

# Sync to Git
caf sync push

# Pull on another machine
caf sync pull
```

### 3. **Distributed Fleet**
Manage multiple nodes (laptop + VPS servers):
```bash
# View all nodes
caf fleet status

# Sync config to all nodes
caf fleet sync

# Apply changes across fleet
caf fleet apply

# Attach to a node via tmux
caf fleet attach
```

## Common Workflows

### Adding a New Language

```bash
# Interactive menu
caf install

# Or directly
caf install python
caf install nodejs
caf install rust
```

This updates `environment.json` and installs the language + LSP + tooling.

### Setting Up a VPS Node

```bash
# Create a new VPS (requires GCP credentials)
caf-vps create my-dev-server

# Or manually on an existing server:
ssh user@server
curl -L https://raw.githubusercontent.com/cafaye/cafaye/master/install.sh | bash
```

### Customizing Your Environment

Edit files in `~/.config/cafaye/config/user/`:
- `zsh/custom.zsh` - Shell aliases and functions
- `tmux/workspace.yml` - Custom tmux windows
- `nvim/` - Editor configuration overrides

Then apply:
```bash
caf apply
```

### Workspace Management

Cafaye uses tmux for session management:
```bash
# Start/attach to workspace
caf-workspace-init --attach

# Preview workspace plan
caf-workspace-run --dry-run

# Customize workspace
vim ~/.config/cafaye/config/user/tmux/workspace.yml
```

## Keyboard Shortcuts

### Shell (zsh)
- **Space** (leader key) - Opens command palette
  - `Space s` - Search/install tools
  - `Space r` - Rebuild environment
  - `Space d` - Show status
  - `Space m` - Main menu
  - `Space Space` - Quick menu (double-tap)
- **Alt+m** - Main menu
- **Alt+s** - Search

### Tmux
- **Prefix: Ctrl+Space**
- `Prefix c` - New window
- `Prefix ,` - Rename window
- `Prefix [1-9]` - Switch to window
- `Prefix d` - Detach

### Neovim (AstroNvim)
- **Leader: Space**
- `Space f f` - Find files
- `Space f g` - Live grep
- `Space e` - File explorer
- `Space /` - Comment toggle

## Troubleshooting

### Installation Issues

**Problem:** "Nix evaluation failed"
```bash
# Check syntax
./cli/scripts/caf-lint

# View detailed logs
cat ~/.config/cafaye/logs/install.log
```

**Problem:** "Home Manager activation failed"
```bash
# Backup conflicting files are created automatically
# Check for .backup files in your home directory
ls -la ~/*.backup*

# Retry
caf apply
```

### Sync Issues

**Problem:** "Git push failed"
```bash
# Check remote
cd ~/.config/cafaye
git remote -v

# Re-add if needed
git remote add origin https://github.com/yourusername/cafaye.git
```

### Fleet Issues

**Problem:** "Cannot reach node"
```bash
# Check Tailscale status
tailscale status

# Or use direct SSH
ssh user@hostname

# Check fleet registry
cat ~/.config/cafaye/secrets/fleet.yaml
```

### Performance Issues

**Problem:** "Zsh startup is slow"
```bash
# Profile startup
CAFAYE_PROFILE_ZSH=1 zsh

# Disable auto-tmux if not needed
export CAFAYE_AUTO_TMUX=0
```

## Getting Help

### Diagnostics

```bash
# System health check
caf-system-doctor

# Collect debug bundle (auto-redacted)
caf-debug-collect

# View logs
ls ~/.config/cafaye/logs/
```

### Resources

- **Documentation**: `~/.config/cafaye/docs/`
- **GitHub Issues**: https://github.com/cafaye/cafaye/issues
- **Logs**: `~/.config/cafaye/logs/`

### Common Commands Reference

```bash
# Core
caf                    # Main menu
caf status            # System status
caf apply             # Apply changes
caf sync push|pull    # Sync config

# Fleet
caf fleet status      # View all nodes
caf fleet sync        # Sync to fleet
caf fleet apply       # Apply to fleet
caf fleet attach      # Attach to node

# VPS
caf-vps list          # List VPS instances
caf-vps create NAME   # Create new VPS
caf-vps delete NAME   # Delete VPS

# Workspace
caf-workspace-init    # Start workspace
caf-workspace-run -n  # Preview workspace

# Diagnostics
caf-system-doctor     # Health check
caf-debug-collect     # Debug bundle
caf-drift             # Check drift
```

## Uninstalling

```bash
cd ~/.config/cafaye
./uninstall.sh

# Or with auto-yes
./uninstall.sh --yes
```

This creates a backup at `~/.config/cafaye.uninstall-backup.{timestamp}` before removing everything.

## Next Steps

1. **Customize your environment**: Edit `~/.config/cafaye/config/user/`
2. **Set up a VPS**: Use `caf-vps create` or manual install
3. **Configure your editor**: Run `caf-editor-distribution-set`
4. **Join the community**: Star the repo, open issues, contribute!

---

**Pro Tip**: Run `caf-hints` for context-aware tips based on your current setup.
