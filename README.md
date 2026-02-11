# ☕ Cafaye

> The first Development Runtime built for collaboration between humans and AI. Accessible from any device, with autonomous agents that keep working when you don't.

## What is Cafaye?

**Cafaye is a Development Runtime**—not an operating system, not just a set of config files, but a complete development environment that runs wherever you need it.

Think of it as your development environment's home: whether on your laptop, a VPS in the cloud, or both. It packages your tools, configurations, and AI agents into a reproducible, declarative environment that follows you everywhere.

### Key Differences

| Traditional Setup                          | Cafaye                             |
| ------------------------------------------ | ---------------------------------- |
| "Works on my machine"                      | Works on _any_ machine             |
| Hours configuring new laptop               | One command, identical environment |
| AI tools run only when you're at your desk | Autonomous agents work 24/7        |
| Environment drifts over time               | Fully reproducible                 |
| Locked to one device                       | Access from phone, tablet, laptop  |

## 🚀 Quick Start

### Option 1: Local Machine (Mac or Ubuntu)

```bash
# One command to set up your development environment
curl -fsSL https://cafaye.sh | bash
```

That's it! You'll get:

- Pre-configured terminal (Zsh, Zellij, Starship, etc)
- Your choice of editors (Neovim, VS Code, Helix, etc)
- Language runtimes (Ruby, Python, Node, Go, Rust, etc)
- AI tools (Claude Code, Antigravity, Codex, Aider, etc) ready to go
- Beautiful Catppuccin theming throughout(more themes to come)

### Option 2: Self-Hosted VPS (24/7 Access)

```bash
# SSH into your fresh Ubuntu VPS
ssh root@<your-vps-ip>

# Run the installer
curl -fsSL https://cafaye.sh | bash
```

Your VPS becomes a Development Runtime accessible from any device:

- SSH from your laptop
- Browser-based VS Code from your iPad
- Terminal sessions that persist across disconnections
- AI agents that continue working while you're offline

**📚 Need help?** Check out the [Installation Guide](docs/INSTALL.md) for detailed instructions.

---

## 💎 The Philosophy

### 1. **Human-AI Collaboration**

Cafaye orchestrates collaboration between you and AI agents. Use Aider for pair programming, Ollama for local models, and autonomous agents that handle repetitive tasks. The runtime is designed so agents can work alongside you or continue independently.

### 2. **Perfect Reproducibility**

Powered by Nix and Home Manager, your entire environment is declared as code. Move to a new machine? Run one command. Your tools, themes, aliases, and configurations are reconstructed exactly as they were. No more "works on my machine."

### 3. **Access From Any Device**

Your Development Runtime runs in the cloud (or locally) and is accessible via SSH or browser from:

- Your MacBook Pro
- Your iPad at the coffee shop
- Your phone on the train
- Any device with a terminal or browser

### 4. **Always On**

When hosted on a VPS, your environment never sleeps:

- Long-running builds continue
- AI agents process tasks overnight
- Terminal sessions persist across disconnections
- Pick up exactly where you left off from any device

### 5. **Zero Configuration**

No need to learn Nix. Edit simple JSON files or use the interactive `caf` CLI. The system handles the complexity—you just declare what you want.

---

## 🆚 Why Cafaye?

### vs. Traditional Dotfiles

| Aspect              | Dotfiles                     | Cafaye                            |
| ------------------- | ---------------------------- | --------------------------------- |
| **Setup time**      | Hours of debugging           | 5 minutes, works guaranteed       |
| **Reproducibility** | "It worked on my old laptop" | Identical on Mac, Ubuntu, or VPS  |
| **AI integration**  | Manual installation          | Built-in agents and orchestration |
| **Multi-device**    | Copy files manually          | Access from anywhere              |
| **Rollback**        | Hope you have backups        | One command to previous state     |

### vs. GitHub Codespaces

| Aspect             | Codespaces                | Cafaye                             |
| ------------------ | ------------------------- | ---------------------------------- |
| **Cost**           | $0.18/hour                | Free (bring your own VPS) or local |
| **Customization**  | Limited container configs | Full system customization with Nix |
| **AI agents**      | Not supported             | First-class autonomous agents      |
| **Portability**    | GitHub only               | Any VPS provider or local machine  |
| **Data ownership** | Microsoft cloud           | Your infrastructure                |

### vs. Omarchy/Omakub

| Aspect           | Omarchy/Omakub      | Cafaye                         |
| ---------------- | ------------------- | ------------------------------ |
| **Base**         | Desktop Linux       | Ubuntu/Nix (local or remote)   |
| **Access**       | Local machine only  | Any device via SSH/browser     |
| **Availability** | When laptop is open | 24/7 on VPS                    |
| **AI focus**     | Desktop tools       | Agent orchestration & autonomy |
| **Scope**        | Personal setup      | Personal + team collaboration  |

---

## 📂 Project Structure

```text
.
├── install.sh              # One-command installer
├── cli/                    # The "caf" CLI (TUI with gum)
│   └── scripts/            # Individual caf-* commands
│
├── core/                   # System configuration
│   ├── nix/               # Nix package manager setup
│   └── auto-shutdown.nix  # Cost-saving automation
│
├── modules/               # The building blocks
│   ├── languages/         # Ruby, Python, Node, Go, Rust
│   ├── frameworks/        # Rails, Django, Next.js templates
│   ├── services/          # PostgreSQL, Redis, Docker
│   ├── editors/           # Neovim, VS Code Server, Helix
│   └── ai/                # Ollama, Aider integration
│
├── interface/             # The Omarchy-inspired aesthetic
│   ├── terminal/          # Zsh, Zellij, Starship configs
│   ├── themes/            # Catppuccin and other themes
│   └── tools.nix          # Modern CLI tools (zoxide, eza, bat)
│
├── config/                # Default configurations
│   ├── terminal/          # Shell configs, git, btop
│   ├── editors/           # Editor defaults
│   └── themes/            # Theme files and templates
│
├── user/                  # User state (JSON-based)
│   ├── user-state.json    # Your environment choices
│   └── user-state.schema.json  # Validation schema
│
├── tests/                 # Test suite
│   ├── install/         # Installation tests
│   ├── core/              # Core functionality tests
│   └── modules/           # Module-specific tests
│
└── docs/                  # Documentation
    ├── INSTALL.md         # Installation guide
    ├── SETUP.md           # Configuration guide
    └── VPS.md     # VPS-specific instructions
```

---

## 🚀 Key Features

### Easy to Use

- **The `caf` CLI**: A beautiful TUI menu. Add Rails? One click—Ruby and PostgreSQL configure automatically.
- **No Nix Knowledge Required**: Edit JSON, run `caf apply`. The system handles the Nix complexity.
- **Docker Services**: One command to spin up PostgreSQL, Redis, MySQL, MongoDB.
- **Auto-Shutdown**: Built-in cost-saving for VPS instances—powers off after inactivity.

### AI-Native

- **AI Coding Agents**: Ready for Claude Code, Codex, Aider, OpenCode, Antigravity, and more
- **Autonomous Agents**: Run agents that continue working when you're offline
- **Ollama**: Local LLM hosting for privacy and offline work
- **Agent Orchestration**: Schedule tasks, run background jobs, automate workflows
- **Easy to Add**: One command to install any AI tool: `caf install claude-code`

### Beautiful & Productive

- **Catppuccin Mocha**: Stunning theme throughout all tools
- **Zellij**: Tiling terminal that feels like a window manager
- **Starship Prompt**: Git status, Tailscale connection, active AI model—at a glance
- **Modern CLI Stack**: zoxide, eza, bat, fd, ripgrep, fzf, btop, lazygit—all pre-configured

### Safe & Reproducible

- **Declarative Configuration**: Your entire environment in Git
- **Atomic Updates**: Changes apply only if they work—automatic rollback on failure
- **Versioned Packages**: Exact versions locked, reproducible across machines
- **Secret Management**: API keys encrypted with sops, injected at runtime

### Multi-Device Access

- **SSH**: Native terminal access from any device
- **Browser IDE**: VS Code Server accessible from phones, tablets, laptops
- **Persistent Sessions**: Zellij sessions survive disconnections—resume anywhere
- **Tailscale Integration**: Secure mesh VPN, no open ports needed

---

## 🛠 Installation Options

### Local Installation (Mac or Ubuntu)

```bash
# Install on your MacBook or Ubuntu desktop
curl -fsSL https://cafaye.sh | bash

# Configure your environment
caf-setup
```

Perfect for:

- Personal development machine
- Syncing environment across multiple computers
- Trying Cafaye before committing to a VPS

### VPS Installation (24/7 Runtime)

```bash
# SSH into your fresh Ubuntu VPS
ssh root@<your-vps-ip>

# Install Cafaye
curl -fsSL https://cafaye.sh | bash

# Configure
ssh root@<your-vps-ip>
caf-setup
```

Perfect for:

- Development from any device
- Running AI agents 24/7
- Team collaboration
- Consistent environment across team members

**Requirements:**

- Fresh VPS with Ubuntu 22.04/24.04 or Debian 12
- At least 2GB RAM (1GB works with ZRAM)
- Root SSH access

**Recommended VPS Providers:**

- Hetzner Cloud (€5/month, excellent value)
- DigitalOcean ($6/month, great docs)
- AWS/GCP/Azure (if you have credits)

---

## 💻 Local Development

**Prerequisites:**

- Devbox (manages Nix environment)
- Docker (for full integration tests)

**Steps:**

1. **Install Devbox:**

   ```bash
   curl -fsSL https://get.jetpack.io/devbox | bash
   ```

2. **Clone and enter development environment:**

   ```bash
   git clone https://github.com/kaka-ruto/cafaye
   cd cafaye
   devbox shell
   ```

3. **Run tests:**

   ```bash
   # Fast syntax check
   bash bin/test.sh

   # Full integration tests
   devbox run test-full
   ```

---

## 🧪 Testing

Cafaye has comprehensive testing built-in:

### Quick Local Testing

```bash
# Validate syntax and structure (~10 seconds)
bash bin/test.sh
```

### Full Integration Tests

```bash
# Run complete VM tests in Docker
devbox run test-full
```

### Individual Tests

```bash
# Test specific modules
nix build .#checks.x86_64-linux.modules-languages-ruby
nix build .#checks.x86_64-linux.modules-frameworks-rails
```

---

## 📖 Documentation

- **[Installation Guide](docs/INSTALL.md)** - Detailed installation instructions
- **[Setup Guide](docs/SETUP.md)** - Configuration and customization
- **[VPS Installation](docs/VPS-INSTALL.md)** - VPS-specific setup
- **[Contributing](CONTRIBUTING.md)** - How to contribute
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development roadmap
- **[AGENTS.md](AGENTS.md)** - AI developer instructions
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🔧 Extensible & Customizable

**Cafaye provides the foundation. You bring your tools.**

### AI Agents Galore

Cafaye is designed to host any AI coding agent:

```bash
# Install any AI tool you prefer
caf install claude-code    # Anthropic's Claude Code
caf install codex          # OpenAI's Codex CLI  
caf install aider          # Aider.chat pair programming
caf install opencode       # OpenCode AI agent
caf install antigravity    # Antigravity AI
# ... and any other agent you discover
```

**Your AI agents, your choice.** We don't lock you into one solution.

### Add Any Tool

Missing something? The Nix ecosystem has 80,000+ packages:

```bash
# One-command install from 80,000+ Nix packages
caf install rust-analyzer
caf install cargo-watch
caf install websocat
# ... literally anything
```

Or add to your `home.nix` for declarative management:

```nix
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Cafaye provides the basics
    ruby nodejs neovim zellij
    
    # You add the rest
    claude-code
    rust-analyzer
    your-custom-tool
  ];
}
```

### Custom Scripts & Hooks

```bash
# Run custom scripts on events
caf hook add post-update "./scripts/notify-slack.sh"

# Extend the menu
caf menu add "Deploy Staging" "./scripts/deploy.sh staging"
```

### Not Opinionated About Your Stack

**We don't force choices:**
- ❌ Not "you must use Neovim"
- ✅ "Use Neovim, VS Code, or Helix—your call"

- ❌ Not "you must use PostgreSQL"  
- ✅ "PostgreSQL, MySQL, SQLite—we set up what you want"

- ❌ Not "you must use our AI"
- ✅ "Claude, GPT, local models—bring your own AI"

**Cafaye is the runway. You choose the plane.**

## 💾 Save, Sync & Restore Your Environment

**Your environment is yours. Save it, move it, share it.**

### Export Your Environment

```bash
# Export your complete environment configuration
caf export ~/my-cafaye-backup.tar.gz

# What's included:
# - ~/.config/home-manager/ (all your configs)
# - ~/.config/cafaye/ (Cafaye settings)
# - ~/.zshrc, ~/.gitconfig (dotfiles)
# - List of installed packages
# - Custom themes and modifications
```

### Import During Installation

```bash
# Fresh machine? Restore your exact environment
curl -fsSL https://cafaye.sh | bash -s -- --import ~/my-cafaye-backup.tar.gz

# Or after installation:
caf import ~/my-cafaye-backup.tar.gz
```

### Store in Git (Recommended)

Your environment is declarative—perfect for version control:

```bash
# Your configs live in ~/.config/home-manager/
cd ~/.config/home-manager

git init
git add .
git commit -m "My perfect dev environment"
git push origin main

# On any new machine:
git clone https://github.com/yourusername/cafaye-env ~/.config/home-manager
caf apply
```

### Migration Examples

**Laptop → VPS:**
```bash
# On your laptop
caf export ~/backup.tar.gz
scp ~/backup.tar.gz vps:~/

# On your VPS
curl -fsSL https://cafaye.sh | bash -s -- --import ~/backup.tar.gz
# Same environment, now running 24/7
```

**VPS → New VPS:**
```bash
# Export from old VPS
caf export ~/backup.tar.gz

# Download and upload to new VPS
# Then install with import
```

**Mac → Ubuntu:**
```bash
# Works across operating systems!
# Export on Mac, import on Ubuntu
# Your shell, editors, and tools transfer perfectly
```

### The Config File

Everything is defined in `~/.config/home-manager/home.nix`:

```nix
{ config, pkgs, ... }: {
  # Your exact tool versions
  home.packages = with pkgs; [
    ruby_3_3
    nodejs_20
    neovim
    zellij
    # ... every tool you use
  ];
  
  # Your exact configurations
  programs.zsh.shellAliases = {
    gs = "git status";
    deploy = "./scripts/deploy.sh production";
  };
  
  # Your dotfiles
  home.file.".config/nvim/init.lua".source = ./nvim/init.lua;
}
```

**This is infrastructure as code for your development environment.**

---

## 🆓 Open Source & Free

**Cafaye is completely free and open source.**

- Self-host on your own VPS (pay only for the VPS)
- Run locally on your Mac or Linux machine
- No managed service (yet)
- No subscription fees
- Apache 2.0 License

**Future:** We may offer managed hosting and team features in the future, but the core platform will always be free and open source.

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

Built with ☕ and Nix. The future of development is autonomous.
