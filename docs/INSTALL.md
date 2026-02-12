# Installing Cafaye

Cafaye provides a reproducible development environment that works on your local machine or a VPS.

## 🚀 Quick Start

### Option 1: Local Machine (macOS or Ubuntu)

```bash
# One command installs everything
curl -fsSL https://cafaye.sh | bash
```

### Option 2: VPS (24/7 Access)

```bash
# SSH into your fresh VPS
ssh root@<your-vps-ip>

# Run the installer
curl -fsSL https://cafaye.sh | bash
```

The installer will:
1. Install Nix package manager
2. Install Home Manager
3. Set up your development environment
4. Configure your chosen tools

---

## 📋 Prerequisites

### Local Installation

| Requirement | Details |
|------------|---------|
| **OS** | macOS 14.0+ or Ubuntu 22.04/24.04 |
| **RAM** | 4GB+ recommended |
| **Shell** | Bash or Zsh |
| **Git** | Required for version control |

### VPS Installation

| Requirement | Details |
|------------|---------|
| **VPS** | Ubuntu 22.04/24.04 or Debian 12 (fresh install) |
| **RAM** | 2GB+ recommended (1GB works with swap) |
| **SSH** | Root access with SSH key authentication |
| **Disk** | 20GB+ free space |

---

## ☁️ Recommended VPS Providers

| Provider | Plan | RAM | Price/mo | Notes |
|----------|------|-----|----------|-------|
| Hetzner | CAX11 | 4GB | €4.38 | Best value, EU locations |
| Hetzner | CPX11 | 2GB | €3.29 | Intel processors |
| DigitalOcean | Basic | 2GB | $4.00 | Good documentation |
| Vultr | Basic | 1GB | $3.50 | Cheap entry point |

---

## 🔧 Installation Process

The installer is interactive and will guide you through:

### 1. Development Preset

Choose your stack:
- **Ruby on Rails Developer** - Ruby, PostgreSQL, Rails
- **Python Django Developer** - Python, PostgreSQL, Django
- **Node.js/React Developer** - Node.js, npm/yarn, React tools
- **Go Backend Developer** - Go, standard tools
- **Rust Systems Developer** - Rust, Cargo
- **Full-Stack Developer** - Multiple languages
- **Custom Configuration** - Pick and choose

### 2. Code Editor

Select your preferred editor:
- **Neovim** - With LazyVim, AstroNvim, or NvChad
- **VS Code** - Via code-server for remote access
- **Helix** - Modern modal editor

### 3. AI Tools (Optional)

Enable AI coding assistants:
- **Aider** - AI pair programming
- **Ollama** - Local LLM hosting
- Or skip and add later with `caf install`

### 4. SSH Keys

The installer will:
- Detect existing SSH keys
- Import them for server access
- Set up secure authentication

---

## ☁️ Tailscale Setup (Optional but Recommended)

Tailscale provides secure, zero-trust access to your VPS.

### During VPS Installation

The installer asks about Tailscale:

1. **Have an account?** → Enter your auth key
2. **Need an account?** → Visit tailscale.com to sign up
3. **Skip** → Configure manually later

**Auth key format:** `tskey-auth-xxxxx...`

Get a reusable auth key at: https://login.tailscale.com/admin/settings/keys

### Benefits

| Benefit | Description |
|--------|-------------|
| **Zero open ports** | SSH only via Tailscale VPN |
| **Access from anywhere** | Phone, laptop, tablet |
| **End-to-end encryption** | All traffic encrypted |
| **No firewall rules** | Tailscale handles access |

### Without Tailscale

Cafaye works without Tailscale:
- SSH accessible directly (less secure)
- All features work normally
- Use strong passwords and SSH keys

---

## 📖 Post-Installation

After installation completes:

```bash
# Your environment is ready!
# All tools are installed and configured

# Start coding
nvim                    # Launch Neovim
code-server             # Launch VS Code in browser

# Terminal multiplexing
tmux                    # Tiling terminal

# Main menu
caf                     # Interactive configuration menu
```

### First Steps

```bash
# Check what's installed
caf doctor              # Verify installation

# View configuration
cat ~/.config/home-manager/home.nix

# Make changes
caf config              # Interactive configuration
# or edit directly:
nano ~/.config/home-manager/home.nix

# Apply changes
caf apply
```

---

## 💾 Backup Your Environment

After setting up, export your configuration:

```bash
# Create backup
caf export ~/cafaye-backup.tar.gz

# Store in safe location (Git recommended)
cd ~/.config/home-manager
git init
git add .
git commit -m "My Cafaye environment"
```

---

## 🔧 Troubleshooting

### Installation Fails

```bash
# Check system requirements
uname -m              # Should be x86_64 or aarch64
cat /etc/os-release   # Should show Ubuntu/Debian

# Check available space
df -h

# Check logs
cat /tmp/cafaye-install.log
```

### Nix Installation Issues

If Nix fails to install:
```bash
# Check for existing Nix
which nix

# Remove old Nix if needed
rm -rf ~/.nix /nix

# Retry installer
curl -fsSL https://cafaye.sh | bash
```

### Permission Denied

Ensure you're running as the correct user:
```bash
# For VPS: Should be root or user with sudo
whoami

# For local: Regular user (not root)
whoami  # Should show your username
```

---

## 🛠 Manual Installation (Advanced)

For more control:

```bash
# Clone repository
git clone https://github.com/kaka-ruto/cafaye
cd cafaye

# Install Nix if not present
curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

# Copy example configuration
cp user/user-state.json.example user/user-state.json

# Edit configuration
nano user/user-state.json

# Run installer
./install.sh
```

---

## 📚 More Information

- [Setup Guide](SETUP.md) - Configuration details
- [Architecture](../ARCHITECTURE.md) - System design
- [Development](../DEVELOPMENT.md) - Contributing guide
- [GitHub](https://github.com/kaka-ruto/cafaye)
