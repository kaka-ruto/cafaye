# Setup Guide

After installation, configure your development environment using the setup wizard or manual configuration.

## Quick Setup

```bash
# Run the interactive setup wizard
caf setup
```

## What the Wizard Does

The `caf setup` wizard guides you through:

### 1. Quick Start Presets

Choose from pre-configured development environments:

- **Ruby on Rails Developer** - Ruby + Rails + PostgreSQL + Neovim
- **Python Django Developer** - Python + Django + PostgreSQL + Neovim
- **Node.js/React Developer** - Node.js + Next.js + Docker + Neovim
- **Go Backend Developer** - Go + Docker + Helix
- **Rust Systems Developer** - Rust + Docker + Helix
- **Full-Stack Developer** - Multiple languages + tools
- **Custom Configuration** - Manually select each component

### 2. Editor Selection

If you chose Custom Configuration, select your preferred editor:

- **Neovim** - Modal editor with distribution options:
  - LazyVim (modern plugin manager)
  - AstroNvim (IDE-like experience)
  - NvChad (fast, beautiful)
- **Helix** - Modern modal editor with built-in LSP
- **VS Code Server** - Browser-based IDE (access via SSH tunnel)

### 3. Development Stack

Customize your environment:

**Programming Languages** (multi-select):
- Ruby, Python, Node.js, Go, Rust

**Web Frameworks** (optional):
- Rails, Django, Next.js

**Database Services** (multi-select):
- PostgreSQL, Redis, MySQL, MongoDB

**AI Tools** (optional):
- Aider (AI pair programming)
- Ollama (local LLM hosting)
- Or add others later with `caf install`

### 4. Additional Configuration

- **Theme** - Catppuccin Mocha, Latte, Tokyo Night, Gruvbox, Nord
- **Auto-shutdown** (VPS only) - Enable to save costs
- **Tailscale** - Configure secure access

## Applying Changes

Once configured, the wizard will:

1. Update `~/.config/home-manager/home.nix` with your selections
2. Run `home-manager switch` to apply changes
3. Set up services and configurations
4. Your environment is ready!

## Manual Configuration

You can also configure manually:

```bash
# Edit configuration directly
nano ~/.config/home-manager/home.nix

# Or use the CLI
caf config

# Apply changes
caf apply
```

## Running Setup Again

To reconfigure at any time:

```bash
caf setup
```

This preserves existing settings but allows modifications.

## Verification

Check your setup:

```bash
# Verify installation
caf doctor

# View system details
caf about

# Check available tools
which ruby && ruby --version
which node && node --version
```

## Next Steps

- **Start coding:** Launch your editor (`nvim`, `code-server`, or `hx`)
- **Learn the CLI:** Run `caf` to see available commands
- **Backup your config:** `caf export ~/backup.tar.gz`
- **Read documentation:** See [README.md](../README.md) for full details

## Troubleshooting

If setup fails:

```bash
# Check Nix installation
nix --version

# Check Home Manager
home-manager --version

# View logs
cat ~/.local/state/cafaye/setup.log

# Reset to defaults
caf reset
```
