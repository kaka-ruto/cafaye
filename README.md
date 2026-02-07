# ☕ Cafaye OS

> An AI-first developer OS that turns any cheap VPS into a secure, cloud-native powerhouse accessible from any device.

Cafaye (pronounced _ca-fay_) brings the luxury, keyboard-driven experience of [Omarchy](../omarchy/) to the cloud. It's a modern, highly opinionated server operating system built on NixOS—designed to be easy to use, easy to extend, beautiful, safe, secure, fast, powerful, and accessible from anywhere.

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

## 🆚 Cafaye vs Omarchy

| Aspect       | Omarchy              | Cafaye                      |
| :----------- | :------------------- | :-------------------------- |
| **Target**   | Desktop (Arch Linux) | Server (Any VPS)            |
| **Display**  | Hyprland (Wayland)   | Zellij (Terminal)           |
| **Access**   | Local keyboard/mouse | SSH + Browser anywhere      |
| **Graphics** | Full GPU support     | Headless, no GPU needed     |
| **Base**     | `pacman` + AUR       | Nix Flakes                  |
| **Security** | Local firewall       | Zero-trust (Tailscale-only) |
| **Cost**     | Your hardware        | $5/month VPS                |

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

## 🏗 Getting Started

```bash
# Transform any VPS into a Cafaye Powerhouse
curl -fsSL https://cafaye.com/install.sh | bash

# Or, for development
git clone https://github.com/kaka-ruto/cafaye
cd cafaye
devbox shell       # macOS/Linux dev environment
nix flake check    # Run the test suite
```

## 📖 Documentation

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Detailed roadmap with phase checklists
- **[AGENTS.md](AGENTS.md)** - AI developer instructions
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[RELEASING.md](RELEASING.md)** - How to cut a release
