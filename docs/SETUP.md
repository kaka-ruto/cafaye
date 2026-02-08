# Setup Guide

After installation, log into your new Cafaye OS machine and run setup wizard:

```bash
caf-setup
```

## What it does

The `caf-setup` wizard is an interactive TUI (Terminal User Interface) that guides you through:

### 1. Quick Start Presets

Choose from pre-configured development environments:

- **Ruby on Rails Developer** - Ruby + Rails + PostgreSQL + LazyVim
- **Python Django Developer** - Python + Django + PostgreSQL + LazyVim
- **Node.js/React Developer** - Node.js + Next.js + Docker + LazyVim
- **Go Backend Developer** - Go + Docker + Helix
- **Rust Systems Developer** - Rust + Docker + Helix
- **Full-Stack Developer** - Python/Node.js + Django/Next.js + PostgreSQL/Redis + LazyVim
- **Custom Configuration** - Manually select each component

### 2. Editor Selection

If you chose Custom Configuration, select your preferred editor:

- **Neovim** - Modal editor with distribution options:
  - LazyVim (modern plugin manager)
  - AstroNvim (IDE-like experience)
  - NvChad (fast, beautiful)
- **Helix** - Modern modal editor with built-in LSP
- **VS Code Server** - Browser-based IDE (Tailscale access only)

### 3. Development Stack

Customize your development environment:

**Programming Languages** (multi-select):
- Ruby, Python, Node.js, Go, Rust, PHP, Java

**Web Frameworks** (optional):
- Rails, Django, Next.js, Laravel, Express, Spring Boot, Phoenix

**Database Services** (multi-select):
- PostgreSQL, Redis, MySQL, MongoDB, Elasticsearch

### 4. Additional Configuration

- **Theme** - Catppuccin Mocha, Latte, Tokyo Night, Gruvbox, Nord
- **ZRAM** - Enable/disable memory compression (recommended for 1GB RAM)
- **Tailscale** - Configure secure access if not already set up
- **Security** - Option to disable bootstrap_mode (opens SSH to world if enabled)

## Applying Changes

Once configured, the wizard will:

1. Update `/etc/cafaye/user-state.json` with your selections
2. Rebuild NixOS configuration (`sudo nixos-rebuild switch`)
3. Run post-setup hooks
4. Reload your shell and environment

## Running Again Later

To reconfigure your system at any time:

```bash
caf-setup
```

This will preserve your existing settings but allow you to modify any component.

## Adding TailScale Later

If you skipped TailScale during installation, you can add it later:

```bash
sudo caf-tailscale-setup
```

## Verification

To verify your setup:

- Run `caf-system-doctor` to check system health
- Run `caf-about-show` to see system details
- Launch your editor with `caf-editor-launch`
- Access VS Code Server at `http://<tailscale-ip>:8080` (if enabled)
