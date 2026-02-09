# ☕ Cafaye OS

> An AI-first developer OS that turns any cheap VPS into a secure, cloud-native powerhouse accessible from any device.

## 🚀 Quick Start

**Two simple steps:**

```bash
# Step 1: SSH into your fresh VPS
ssh root@<your-vps-ip>

# Step 2: Run the installer
bash <(curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh)
```

That's it! The installer will:

1. Install Nix (multi-user)
2. Clone Cafaye
3. Install NixOS

**After installation:**
```bash
# Your VPS reboots into NixOS
# SSH in again and configure:
ssh root@<your-vps-ip>
caf-setup
```

**📚 Need help?** Check out the [VPS Installation Guide](docs/VPS-INSTALL.md) for detailed instructions, troubleshooting tips, and manual installation steps.

---

## 🆚 Why Cafaye Over Omarchy?

| Aspect | Omarchy | Cafaye |
|--------|---------|--------|
| **One-liner install** | ❌ Clone manually | ✅ `bash <(curl)` |
| **Pre-requisites** | Git + existing Arch | Auto-installs Nix |
| **Target** | Desktop | VPS/Server |
| **Access** | Local machine | SSH + Browser anywhere |
| **Graphics** | GPU required | Headless |
| **Security** | Local firewall | Zero-trust (Tailscale) |
| **Cost** | Your hardware | $5/month VPS |

---

## 💎 The Philosophy

1.  **The "Omarchy" Experience**
    All the polish of Omarchy's desktop, delivered through SSH. Zellij provides tiling windows, Starship delivers a rich prompt, and Catppuccin makes it beautiful. Your terminal _is_ your desktop.

2.  **AI-Native & Agent-Ready**
    Cafaye doesn't just run AI; it orchestrates it. Ollama runs local models, Aider enables AI pair programming, and Continue integrates with your IDE. API keys are securely managed, and everything works in harmony.

3.  **Absolute Reproducibility**
    Powered by Nix Flakes, your entire server is defined as code. Move to a new VPS? Run one command. Your languages, tools, themes, and configurations are reconstructed exactly as they were.

4.  **Zero-Trust Security**
    No open ports. No exposed services. Everything—SSH, VS Code Server, AI dashboards—is locked behind Tailscale. Access your powerhouse from a phone in a cafe or a laptop at home, securely.

5.  **Accessible From Anywhere**
    A browser and Tailscale are all you need. Full VS Code in your browser, persistent terminal sessions that survive disconnects, and mobile-friendly workflows.

## 📂 Project Structure

```text
.
├── flake.nix        # System orchestrator & dependency manager
├── devbox.json      # Local development environment
├── install.sh       # One-liner VPS bootstrap script
├── version          # Current Cafaye version
│
├── core/            # IMMUTABLE ENGINE
│   ├── boot.nix     # Kernel, ZRAM, GRUB
│   ├── network.nix  # Tailscale & DNS
│   └── security.nix # Firewall, SSH via Tailscale only
│
├── interface/       # THE OMARCHY VIBE
│   ├── terminal/    # Zsh, Zellij, Starship
│   ├── tools.nix    # CLI tools (zoxide, eza, bat, fd, ripgrep, fzf)
│   └── theme.nix    # Global theme management
│
├── modules/         # THE LEGO BLOCKS
│   ├── languages/   # Runtimes: Ruby, Python, Node, Rust
│   ├── frameworks/  # Stacks: Rails, Django, Next.js
│   ├── services/    # Daemons: PostgreSQL, Redis, Docker
│   ├── editors/     # Neovim, Helix, VS Code Server
│   │   └── distributions/nvim/  # AstroNvim, LazyVim, NvChad
│   └── ai/          # Ollama, Aider, Continue
│
├── config/          # DEFAULT CONFIGURATIONS
│   ├── terminal/    # zsh, zellij, starship, git, btop, lazygit, fastfetch
│   ├── editors/     # Editor configs (defaults + distributions)
│   ├── themes/      # Catppuccin colors & tool-specific themes
│   ├── templates/   # Theme templates with {{ color }} placeholders
│   └── cafaye/      # User extensibility
│       ├── hooks/       # post-update, theme-set, rebuild-complete
│       ├── extensions/  # User menu overrides
│       └── branding/    # ASCII logo, about text
│
├── cli/             # THE "CAF" CLI (TUI with gum)
├── user/            # THE STATE (JSON-based user choices)
├── secrets/         # ENCRYPTED SECRETS (sops-nix)
├── tests/           # THE MIRROR (1:1 test mapping)
└── .github/         # THE FACTORY (CI/CD & Cachix)
```

## 🚀 Key Features

### Easy to Use

- **The `caf` CLI**: A beautiful TUI menu (inspired by `omarchy-menu`). Install Rails with one click—Ruby and PostgreSQL are configured automatically.
- **No Nix Knowledge Required**: Edit JSON, run `caf apply`. That's it.
- **Docker Databases**: One command to spin up MySQL, PostgreSQL, Redis, MongoDB.

### Easy to Extend

- **Hook System**: Add custom scripts for `post-update`, `theme-set`, `rebuild-complete`.
- **Menu Extensions**: Override or extend the `caf` menu with your own options.
- **Modular Architecture**: Add a language runtime in one `.nix` file.

## 🚀 Post-Installation

Once the installer detaches and the VPS reboots, Cafaye OS will generate its own secure host keys. Because these differ from the original Ubuntu keys, your first connection attempt might show a scary warning: **"REMOTE HOST IDENTIFICATION HAS CHANGED!"**

Don't panic! This is expected. Run the following on your local machine to refresh the connection:

```bash
# Clear the old host identity
ssh-keygen -R <vps-ip-or-alias>

# Connect to your new Cafaye OS
ssh root@<vps-ip-or-alias>
```

---

### Beautiful

- **Catppuccin Mocha**: The same stunning theme from Omarchy, everywhere.
- **Starship Prompt**: Git status, Tailscale connection, active AI model—all at a glance.
- **Zellij**: Tiling terminal that feels like a window manager.
- **Fastfetch**: Beautiful system info on every login.

### Developer Luxury

- **Modern CLI Tools**: zoxide, eza, bat, fd, ripgrep, fzf, btop, lazygit—all pre-configured.
- **Git Config**: Sensible aliases and settings (rebase on pull, auto setup remote).
- **Theme Templates**: `{{ color }}` placeholders for consistent theming across tools.

### Safe & Secure

- **Zero Open Ports**: Tailscale mesh VPN only. No firewall rules to manage.
- **Encrypted Secrets**: API keys stored with sops-nix, encrypted at rest.
- **Immutable Infrastructure**: NixOS means no configuration drift.

### Fast & Powerful

- **Binary Caching**: Cachix pre-builds everything. A $5 VPS installs in minutes.
- **ZRAM**: Efficient memory compression for RAM-constrained instances.
- **Optimized for VPS**: KVM/QEMU guest tweaks out of the box.

### Accessible From Anywhere

- **Browser IDE**: VS Code Server accessible over Tailscale from any device.
- **Persistent Sessions**: Zellij sessions survive disconnects. Resume on any device.
- **Mobile Friendly**: SSH from your phone, pick up where you left off.

## 🛠 For AI Developers

When developing Cafaye, reference the local Omarchy repository (`../omarchy/`):

1.  **Command Patterns**: Mirror `omarchy-*` naming with `caf-*` prefix
2.  **Menu Design**: Study `../omarchy/bin/omarchy-menu` for TUI inspiration
3.  **Theme Colors**: Use `../omarchy/themes/catppuccin/colors.toml`
4.  **Prompt Config**: Adapt `../omarchy/config/starship.toml`
5.  **Mirror Testing**: Every module in `modules/` needs a test in `tests/`

## 🏗 Install on VPS

**Two simple steps:**

```bash
# Step 1: SSH into your fresh VPS
ssh root@<your-vps-ip>

# Step 2: Run the installer
bash <(curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh)
```

The installer will:

1. Detect Debian/Ubuntu
2. Install Nix (multi-user)
3. Clone Cafaye
4. Install NixOS
5. VPS reboots into Cafaye OS

**After installation:**

```bash
# SSH into your new Cafaye OS
ssh root@<your-vps-ip>

# Configure your development environment
caf-setup
```

---

**What you'll need:**
- A fresh VPS (Ubuntu 24.04 or Debian 12)
- At least 2GB RAM (1GB works with ZRAM)
- Root SSH access

---

## 💻 Local Development

**Prerequisites:**
- Devbox (manages Nix environment)
- Docker (for full integration tests)

**Steps:**

1. **Install Devbox (if not already installed):**
   ```bash
   curl -fsSL https://get.jetpack.io/devbox | bash
   ```

2. **Clone and enter the development environment:**
   ```bash
   git clone https://github.com/kaka-ruto/cafaye
   cd cafaye
   devbox shell       # macOS/Linux dev environment
   nix flake check    # Run the test suite
   ```

3. **Run full integration tests in Docker (Recommended before pushing):**
   ```bash
   devbox run test-full
   ```
   Or manually (force amd64 to match VPS architecture):
   ```bash
   docker build --platform linux/amd64 -t cafaye-factory .
   docker run --platform linux/amd64 --rm -it cafaye-factory
   ```

 ## 🧪 Testing
 
 Cafaye has comprehensive testing built in. Tests run in CI on every push, and you can run them locally too.
 
 ### Quick Local Testing (No VMs, ~10 seconds)
 
 Run the local test script before pushing to CI:
 
 ```bash
 ./bin/test-local.sh
 ```
 
 This validates Nix syntax, script syntax, JSON state, and module imports without booting VMs.
 
 ### Monitor CI Status
 
 Use the `caf-factory-check` CLI to monitor your CI/CD builds:
 
 ```bash
 # Check latest CI run
 caf-factory-check --latest
 
 # Check specific commit
 caf-factory-check --commit abc1234
 
 # View error logs inline
 caf-factory-check --logs
 
 # Watch CI continuously
 caf-factory-check --watch
 
 # Check current commit status
 caf-factory-check --commit $(git rev-parse --short HEAD)
 ```
 
 ### Run Individual Tests
 
 For focused debugging, run specific tests:
 
 ```bash
 # Unified tests (what CI runs - fast)
 nix build .#checks.x86_64-linux.core-unified
 nix build .#checks.x86_64-linux.cli-unified
 nix build .#checks.x86_64-linux.modules-unified
 
 # Individual tests (for debugging specific components)
 nix build .#individualChecks.x86_64-linux.core-boot
 nix build .#individualChecks.x86_64-linux.cli-main
 nix build .#individualChecks.x86_64-linux.modules-languages
 ```
 
 ### Full Integration Tests (Docker)
 
 Run complete VM tests in isolation:
 
 ```bash
 # Using devbox (recommended)
 devbox run test-full
 
 # Or manually with Docker
 docker build --platform linux/amd64 -t cafaye-factory .
 docker run --platform linux/amd64 --rm -it cafaye-factory
 ```
 
 ## 📖 Documentation
 
 - **[Installation Guide](docs/INSTALL.md)** - How to install on a VPS
  - **[Setup Guide](docs/SETUP.md)** - Configuration wizard details
 - **[Contributing](CONTRIBUTING.md)** - Development guidelines
 - **[DEVELOPMENT.md](DEVELOPMENT.md)** - Detailed roadmap with phase checklists
 - **[AGENTS.md](AGENTS.md)** - AI developer instructions
 - **[CHANGELOG.md](CHANGELOG.md)** - Version history
 - **[RELEASING.md](RELEASING.md)** - How to cut a release
