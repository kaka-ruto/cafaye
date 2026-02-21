# Installing Cafaye

Cafaye provides a reproducible development environment that works on your local machine or a VPS.

## 🚀 Quick Start

### Option 1: Automated Installation

```bash
# Works on macOS (Intel/M-series) and Ubuntu/Debian
curl -fsSL https://raw.githubusercontent.com/cafaye/cafaye/master/install.sh | bash
```

### Option 2: Manual Clone

```bash
git clone https://github.com/cafaye/cafaye.git ~/.config/cafaye
cd ~/.config/cafaye
./install.sh
```

---

## 📋 Prerequisites

| Requirement | Details |
|------------|---------|
| **OS** | macOS 14.0+ or Ubuntu 22.04/24.04+ |
| **RAM** | 2GB+ (4GB recommended) |
| **Disk** | 10GB free space |
| **Network** | Internet access for initial bootstrap |

---

## 🔧 Installation Flow

The installer is interactive and uses `gum` for a premium terminal experience.

### 1. Identity & Backups
- Set your Git name and email.
- Choose a backup repository (GitHub/GitLab) to store your `cafaye` configuration.

### 2. Editor & UI
- **Editor**: Choose between Neovim (with LazyVim/AstroNvim), Helix, or VS Code Server.
- **Theme**: Select a beautiful terminal theme (Catppuccin Mocha, Tokyo Night, etc.).

### 3. Distributed Fleet
- **Tailscale**: Optionally set up a zero-config VPN for secure multi-node access.
- **VPS Mode**: Enable server-specific optimizations like auto-shutdown and SSH keys.

### 4. Build & Apply
- The installer installs **Nix** (if missing).
- It uses **Home Manager** to build your environment.
- All configuration is stored declaratively in `~/.config/cafaye/`.

---

## 📖 Post-Installation

The following commands are your primary entry points:

```bash
# Main interactive menu
caf

# Show status and diagnostics
caf status
caf doctor

# Install language stacks
caf install ruby
caf install rails

# Apply declarative changes
caf apply
```

---

## 💾 Configuration Structure

All your settings live in `~/.config/cafaye/`:

- `environment.json`: Enabled languages, frameworks, and tools.
- `settings.json`: Your Git identity, backup URLs, and core preferences.
- `local-user.nix`: Machine-specific Nix overrides (automatically generated).
- `config/user/`: Your personal configuration overrides for Zsh, TMUX, and Editors.

---

## 🏥 Troubleshooting

### Logs
Check `~/.config/cafaye/logs/install.log` for detailed installation history.

### Conflicts
If Home Manager fails due to existing files (e.g., `.zshrc`), the installer automatically backs them up with a `.backup` suffix.

### System Health
```bash
caf doctor
```
