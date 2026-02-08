# Installing Cafaye OS

Cafaye OS transforms any fresh VPS into a cloud development powerhouse using NixOS.

## 🚀 Quick Start (Recommended)

**One command. That's it.**

```bash
curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
```

The installer self-downloads if needed, checks dependencies, and runs the interactive installer.

---

## 📋 Prerequisites

| Requirement | Details |
|------------|---------|
| **VPS** | Ubuntu 24.04 or Debian 12 (fresh install) |
| **RAM** | 2GB+ recommended (1GB works with ZRAM) |
| **SSH** | Root access with SSH key authentication |
| **Disk** | Any supported disk device |

---

## ☁️ Supported VPS Providers

| Provider | Plan | RAM | Price/mo |
|----------|------|-----|----------|
| Hetzner | CAX11 | 4GB | €4.38 |
| Hetzner | CPX11 | 2GB | €3.29 |
| DigitalOcean | Basic | 2GB | $4.00 |
| Vultr | Basic | 1GB | $3.50 |

---

## 🔧 Disk Configuration

Cafaye uses `nixos-anywhere` which automatically partitions and formats the target disk.

### Auto-Detected Devices

| Device | Provider |
|--------|----------|
| `/dev/vda` | DigitalOcean, Vultr, Hetzner (KVM) |
| `/dev/sda` | Hetzner (older), Xen |
| `/dev/nvme0n1` | AWS, GCP, bare metal NVMe |

The installer auto-detects your provider and sets the correct disk device.

---

## 📦 What the Installer Asks

1. **VPS Connection**
   - IP address
   - SSH user (usually `root`)
   - SSH port (usually `22`)

2. **SSH Keys**
   - Add from SSH agent
   - Add from file
   - Paste manually

3. **Tailscale** (optional but recommended)
   - Configure during installation with auth key
   - Or skip and configure later
   - See TailScale section below for details

4. **Development Preset**
   - Ruby on Rails Developer
   - Python Django Developer
   - Node.js/React Developer
   - Go Backend Developer
   - Rust Systems Developer
   - Full-Stack Developer
   - Custom Configuration

5. **Code Editor**
   - Neovim (LazyVim, AstroNvim, NvChad)
   - Helix
   - VS Code Server

---

## ☁️ TailScale Setup

TailScale is **optional but recommended** for secure, zero-trust access.

### During Installation

The installer asks if you want to configure TailScale:

1. **Have an account?** → Enter your auth key
2. **Need an account?** → Opens TailScale signup in browser
3. **Skip** → Configure later manually

**Auth key format:** `tskey-auth-xxxxx...`

Get a reusable auth key at:
- https://login.tailscale.com/admin/settings/keys

### After Installation

**If you skipped TailScale during install:**

```bash
# SSH into your server
ssh root@<your-vps-ip>

# Configure TailScale
sudo tailscale up --auth-key=tskey-auth-xxxxx
```

**If you already have a TailScale account:**
```bash
# Generate auth key (web UI)
# https://login.tailscale.com/admin/settings/keys

# Connect
sudo tailscale up --auth-key=tskey-auth-xxxxx
```

### Benefits of TailScale

| Benefit | Description |
|--------|-------------|
| **Zero open ports** | SSH only via TailScale VPN |
| **Access from anywhere** | Phone, laptop, tablet |
| **End-to-end encryption** | All traffic encrypted |
| **Easy file sharing** | Truebit integration |
| **No firewall rules** | TailScale handles access control |

### Without TailScale

If you don't use TailScale, Cafaye still works:
- SSH accessible from any IP (bootstrap mode can be disabled)
- All features work normally
- Less secure by default

---

## 🔐 Security

By default, Cafaye uses **bootstrap mode** during installation to allow SSH from any IP. After setup:

1. Run `caf-setup` to configure your system
2. The installer will ask to disable bootstrap mode
3. **Bootstrap mode is automatically disabled** for security

After that, SSH is only accessible via Tailscale.

---

## 📖 Post-Installation

After the installer completes:

```bash
# SSH into your new server
ssh root@<your-vps-ip>

# Run first-run setup
caf-setup

# Your system is ready!
nvim        # Start coding
zellij      # Tiling terminal
caf         # Main menu
```

---

## 🛠 Manual Installation (Advanced)

If you need more control:

```bash
# Clone the repository
git clone https://github.com/kaka-ruto/cafaye
cd cafaye

# Edit configuration
cp user/user-state.json.example user/user-state.json
nano user/user-state.json

# Run installer
./install.sh
```

---

## 🔧 Troubleshooting

### Installation Fails

```bash
# Check SSH connectivity
ssh root@<your-vps-ip>

# Verify disk device
ssh root@<your-vps-ip> lsblk

# Check logs
cat /tmp/cafaye-install.log
```

### Can't Connect After Reboot

1. Wait 2 minutes for the system to reboot
2. Check with your VPS provider's console
3. Verify Tailscale status: `tailscale status`

### Need to Reconfigure

```bash
# Edit configuration
sudo nano /etc/cafaye/user-state.json

# Rebuild system
caf-system-rebuild
```

---

## 📚 More Information

- [First Run Guide](FIRST_RUN.md)
- [Documentation](../README.md)
- [GitHub](https://github.com/kaka-ruto/cafaye)
