# 🛠 Cafaye OS: Development Roadmap

Cafaye is the reproducible, AI-first developer OS that turns any cheap VPS into a secure, cloud-native powerhouse accessible from any device.

## 🏗 AI Execution Rules

- **Atomic Development**: Complete, document, and test one feature before moving to the next.
- **The "Factory" First**: CI/CD (GitHub Actions) and Binary Caching (Cachix) must be functional in v0.1.0.
- **The Mirror Testing Rule**: Every directory in `modules/`, `config/`, and `interface/` must have a corresponding test in `tests/`.
- **CLI Naming**: All commands follow the `caf-<thing>-<action>` pattern (e.g., `caf-editor-launch`, `caf-config-refresh`).
- **Reference Omarchy**: Study `../omarchy/` for aesthetic and UX inspiration, but leverage NixOS's declarative nature.

## 🎯 Why NixOS Makes This Simpler

Unlike Omarchy (built on Arch Linux), Cafaye leverages NixOS's superpowers:

| Omarchy Pattern | NixOS Native Solution |
| :--- | :--- |
| Migration scripts | Generations (automatic, atomic) |
| Snapper snapshots | Boot menu rollback |
| Complex update scripts | `nix flake update && nixos-rebuild switch` |
| State toggle files | Declarative in `user-state.json` + rebuild |
| Package version tracking | `flake.lock` pins everything |

**Result**: ~60% less operational tooling needed. Focus on UX, not infrastructure.

## 📂 Full 1.0.0 Directory Structure

```text
.
├── flake.nix             # System entry point & orchestrator
├── flake.lock            # Dependency version pinning
├── devbox.json           # Local dev shell (Mac/Linux/Win)
├── Dockerfile            # Local dev container for macOS users
├── install.sh            # VPS Bootstrap (nixos-anywhere wrapper)
├── version               # Current Cafaye version
│
├── core/                 # IMMUTABLE SYSTEM ENGINE
│   ├── default.nix       # Core imports
│   ├── boot.nix          # Kernel, Zram, & GRUB
│   ├── security.nix      # Tailscale SSH, Sops-nix, & Firewall
│   ├── network.nix       # Tailscale & DNS logic
│   └── hardware.nix  # KVM/QEMU optimizations
│
├── interface/            # THE OMARCHY VIBE (UX/UI)
│   ├── terminal/
│   │   ├── zsh.nix       # Zsh shell configuration
│   │   ├── zellij.nix    # Tiling workspace
│   │   └── starship.nix  # Prompt configuration
│   ├── tools.nix         # CLI tools (zoxide, eza, bat, fd, ripgrep, fzf)
│   └── theme.nix         # Global theme management
│
├── modules/              # THE LEGO BLOCKS (Logic)
│   ├── languages/
│   │   ├── ruby.nix
│   │   ├── python.nix
│   │   ├── node.nix
│   │   └── rust.nix
│   │
│   ├── frameworks/
│   │   ├── rails.nix     # → languages/ruby + services/postgresql
│   │   ├── django.nix    # → languages/python + services/postgresql
│   │   └── nextjs.nix    # → languages/node
│   │
│   ├── services/
│   │   ├── postgresql.nix
│   │   ├── redis.nix
│   │   └── docker.nix
│   │
│   ├── editors/
│   │   ├── neovim.nix
│   │   ├── helix.nix
│   │   ├── vscode-server.nix
│   │   └── distributions/
│   │       └── nvim/
│   │           ├── astronvim.nix
│   │           ├── lazyvim.nix
│   │           ├── nvchad.nix
│   │           └── lunarvim.nix
│   │
│   └── ai/
│       ├── ollama.nix
│       ├── aider.nix
│       └── continue.nix
│
├── config/               # DEFAULT CONFIGURATIONS
│   ├── terminal/
│   │   ├── zsh/
│   │   │   └── .zshrc
│   │   ├── zellij/
│   │   │   └── config.kdl
│   │   ├── starship/
│   │   │   └── starship.toml
│   │   ├── git/              # Git aliases & settings
│   │   │   └── config
│   │   ├── btop/             # System monitor
│   │   │   └── btop.conf
│   │   ├── lazygit/          # Git TUI
│   │   │   └── config.yml
│   │   └── fastfetch/        # System info display
│   │       └── config.jsonc
│   │
│   ├── editors/
│   │   ├── defaults/
│   │   │   ├── nvim/
│   │   │   ├── helix/
│   │   │   └── vscode/
│   │   └── distributions/
│   │       └── nvim/
│   │           ├── astronvim/
│   │           ├── lazyvim/
│   │           ├── nvchad/
│   │           └── lunarvim/
│   │
│   ├── themes/
│   │   └── catppuccin/
│   │       ├── colors.toml       # Base color definitions
│   │       ├── nvim.lua
│   │       ├── helix.toml
│   │       ├── vscode.json
│   │       ├── zellij.kdl
│   │       ├── starship.toml
│   │       ├── btop.theme
│   │       └── lazygit.yml
│   │
│   ├── templates/            # Themeable config templates
│   │   ├── btop.theme.tpl    # {{ accent }}, {{ background }} placeholders
│   │   └── editors/
│   │       └── nvim/
│   │
│   └── cafaye/               # Extensibility
│       ├── extensions/       # User menu extensions
│       │   └── menu.sh.sample
│       ├── hooks/            # User hook scripts
│       │   ├── post-update.sample
│       │   ├── theme-set.sample
│       │   └── rebuild-complete.sample
│       └── branding/
│           ├── logo.txt      # ASCII art logo
│           └── about.txt     # System description
│
├── cli/                  # THE "CAF" CLI
│   ├── main.sh           # `caf` entry point
│   ├── menus/            # Gum-based TUI screens
│   └── scripts/          # Helper scripts
│
├── user/                 # SYSTEM STATE
│   └── user-state.json   # User choices
│
├── secrets/              # ENCRYPTED SECRETS (sops-nix)
│   ├── secrets.yaml
│   └── .sops.yaml
│
├── tests/                # THE QUALITY MIRROR (1:1 mapping)
│   ├── core/
│   ├── interface/
│   ├── modules/
│   ├── config/
│   ├── cli/
│   └── integration/
│
└── .github/
    └── workflows/
        └── factory.yml
```

## 🎨 Omarchy Patterns to Emulate

### Command Naming Prefixes

Borrowed from `../omarchy/AGENTS.md`:

| Prefix | Purpose | Example |
| :--- | :--- | :--- |
| `cmd-` | Check if commands exist, utilities | `caf-cmd-present git` |
| `config-` | Configuration management | `caf-config-refresh nvim` |
| `editor-` | Editor operations | `caf-editor-launch` |
| `theme-` | Theme management | `caf-theme-set catppuccin` |
| `system-` | System operations | `caf-system-update` |
| `debug-` | Diagnostics | `caf-debug-collect` |
| `docker-` | Docker operations | `caf-docker-db-install` |
| `hook-` | User hooks | `caf-hook-run post-update` |
| `keys-` | Keybinding reference | `caf-keys-show` |

### Reference Files from Omarchy

| Pattern | Omarchy File | Purpose |
| :--- | :--- | :--- |
| Menu System | `bin/omarchy-menu` | TUI menu with gum |
| Config Refresh | `bin/omarchy-refresh-config` | Safe updates with backup |
| Debug Collection | `bin/omarchy-debug` | System diagnostics |
| Dev Env Setup | `bin/omarchy-install-dev-env` | One-command stacks |
| Docker DBs | `bin/omarchy-install-docker-dbs` | Quick database containers |
| Theme Templates | `default/themed/*.tpl` | `{{ color }}` placeholders |
| Hook System | `bin/omarchy-hook` | User-extensible hooks |
| Show Done | `bin/omarchy-show-done` | Completion indicator |
| Git Config | `config/git/config` | Sensible git defaults |
| Fastfetch | `config/fastfetch/config.jsonc` | System info display |
| Btop | `config/btop/btop.conf` | System monitor config |
| Starship | `config/starship.toml` | Prompt configuration |
| Colors | `themes/catppuccin/colors.toml` | Theme colors |

## 🗂 Configuration Management

### Three-Layer Model

```text
┌─────────────────────────────────────────────────────────────────┐
│  Layer 3: USER OVERRIDES (~/.config/...)                        │
│  User's personal customizations. NEVER touched by Cafaye.       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: DISTRIBUTION CONFIGS (/etc/cafaye/editors/dist/...)   │
│  Opinionated configs (AstroNvim, LazyVim). Managed by Cafaye.   │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: SYSTEM DEFAULTS (/etc/cafaye/...)                     │
│  Base Cafaye configs. Immutable via NixOS.                      │
└─────────────────────────────────────────────────────────────────┘
```

### Theme Template System

Borrowed from Omarchy's `default/themed/*.tpl` pattern:

```toml
# config/templates/btop.theme.tpl
theme[main_bg]="{{ background }}"
theme[main_fg]="{{ foreground }}"
theme[hi_fg]="{{ accent }}"
theme[selected_bg]="{{ color8 }}"
```

Colors defined in `config/themes/catppuccin/colors.toml`:

```toml
accent = "#89b4fa"
background = "#1e1e2e"
foreground = "#cdd6f4"
color0 = "#45475a"
# ... etc
```

### Hook System

Users can extend Cafaye with hooks in `~/.config/cafaye/hooks/`:

```bash
# ~/.config/cafaye/hooks/post-update
#!/bin/bash
echo "System updated! Running custom tasks..."
```

Hooks are triggered via `caf-hook-run <name>`.

## 🔐 Secrets Management

| Secret | Purpose | Storage |
| :--- | :--- | :--- |
| **Tailscale Auth Key** | VPN enrollment | `secrets/secrets.yaml` |
| **AI API Keys** | External LLMs | `secrets/secrets.yaml` |
| **Cachix Token** | Binary cache | GitHub Actions |

---

## 📍 Phase 1: v0.1.0 - The Factory

**Goal**: CI/CD pipeline and core bootable system with Tailscale.

### Checklist

- [x] **Project Initialization**
  - [x] Create `flake.nix` with basic NixOS configuration
  - [x] Create `devbox.json` for local development shell
  - [x] Create `Dockerfile` for macOS development
  - [x] Create `version` file (0.1.0)

- [x] **Core System (`core/`)**
  - [x] `core/default.nix` - Import all core modules
  - [x] `core/boot.nix` - GRUB, kernel, ZRAM
  - [x] `core/hardware.nix` - KVM/QEMU optimizations
  - [x] `core/network.nix` - Networking + Tailscale
  - [x] `core/security.nix` - Firewall, SSH via Tailscale only

- [x] **Secrets Setup**
  - [x] `secrets/.sops.yaml` configuration
  - [x] Tailscale auth key encryption

- [x] **CI/CD Pipeline**
  - [x] `.github/workflows/factory.yml`
  - [x] `nix flake check` validation
  - [x] VM boot tests
  - [x] Cachix push

- [x] **Testing**
  - [x] `tests/core/boot.nix`
  - [x] `tests/core/network.nix`
  - [x] `tests/core/security.nix`

### Success Criteria
- [x] VM boots and Tailscale connects
- [x] SSH accessible only via Tailscale
- [x] CI passes and Cachix populated

---

## 📍 Phase 2: v0.2.0 - Terminal Experience

**Goal**: Beautiful terminal with essential CLI tools and theming.

### Checklist

- [x] **Terminal Interface (`interface/terminal/`)**
  - [x] `interface/terminal/zsh.nix` - Zsh with plugins
  - [x] `interface/terminal/zellij.nix` - Tiling multiplexer
  - [x] `interface/terminal/starship.nix` - Prompt

- [x] **Essential CLI Tools (`interface/tools.nix`)**
  - [x] `zoxide` - Smart cd with frecency
  - [x] `eza` - Modern ls with icons
  - [x] `bat` - Cat with syntax highlighting
  - [x] `fd` - Fast find
  - [x] `ripgrep` - Fast grep
  - [x] `fzf` - Fuzzy finder
  - [x] `btop` - System monitor (vim keys enabled)
  - [x] `lazygit` - Git TUI
  - [x] `fastfetch` - System info display

- [x] **Terminal Configs (`config/terminal/`)**
  - [x] `config/terminal/zsh/.zshrc` - Aliases, zoxide init
  - [x] `config/terminal/zellij/config.kdl` - Compact layout, Alt+H/J/K/L
  - [x] `config/terminal/starship/starship.toml` - Git, Tailscale status
  - [x] `config/terminal/git/config` - Aliases (co, br, ci, st), rebase on pull
  - [x] `config/terminal/btop/btop.conf` - Vim keys, theme integration
  - [x] `config/terminal/lazygit/config.yml` - Theme integration
  - [x] `config/terminal/fastfetch/config.jsonc` - Cafaye branding

- [x] **Theme System (`config/themes/`)**
  - [x] `config/themes/catppuccin/colors.toml` - Base color definitions
  - [x] `config/themes/catppuccin/zellij.kdl`
  - [x] `config/themes/catppuccin/starship.toml`
  - [x] `config/themes/catppuccin/btop.theme`
  - [x] `config/themes/catppuccin/lazygit.yml`

- [x] **Template System (`config/templates/`)**
  - [x] `config/templates/btop.theme.tpl` - With `{{ color }}` placeholders
  - [x] `caf-theme-apply` - Generate configs from templates

- [x] **Branding (`config/cafaye/branding/`)**
  - [x] `logo.txt` - ASCII art logo
  - [x] `about.txt` - System description for fastfetch

- [x] **Login Experience**
  - [x] Fastfetch on SSH login (show system info)
  - [x] Auto-start Zellij session

- [x] **Testing**
  - [x] `tests/interface/terminal/zsh.nix`
  - [x] `tests/interface/terminal/zellij.nix`
  - [x] `tests/interface/tools.nix`
  - [x] `tests/config/terminal/`

### Success Criteria
- [x] SSH login shows fastfetch, then Zellij with Starship
- [x] All CLI tools available (zoxide, eza, bat, etc.)
- [x] Catppuccin colors throughout
- [x] Alt+H/J/K/L navigation works

---

## 📍 Phase 3: v0.3.0 - The Caf CLI

**Goal**: TUI management system with state management and extensibility.

### Checklist

- [x] **User State Schema**
  - [x] `user/user-state.json` with JSON schema
  - [x] Document all state fields

- [x] **CLI Core (`cli/`)**
  - [x] `cli/main.sh` - `caf` entry point with gum menu
  - [x] `cli/scripts/state-read.sh`
  - [x] `cli/scripts/state-write.sh`
  - [x] `cli/scripts/rebuild.sh` - Wrapper for `nixos-rebuild`

- [x] **Main Menu (inspired by `omarchy-menu`)**
  - [x] Install submenu
  - [x] Status submenu (system health)
  - [x] Update submenu
  - [x] Theme submenu
  - [x] About submenu (fastfetch)

- [x] **Extensibility (`config/cafaye/`)**
  - [x] `config/cafaye/extensions/menu.sh.sample` - User menu overrides
  - [x] `config/cafaye/hooks/post-update.sample`
  - [x] `config/cafaye/hooks/theme-set.sample`
  - [x] `config/cafaye/hooks/rebuild-complete.sample`
  - [x] `caf-hook-run <name>` - Execute user hooks

- [x] **Utility Commands**
  - [x] `caf-cmd-present <cmd>` - Check if command exists
  - [x] `caf-logo-show` - Display ASCII logo
  - [x] `caf-task-done` - Completion indicator with gum

- [x] **Testing**
  - [x] `tests/cli/main.nix` (Includes Hook tests)

### Success Criteria
- [x] `caf` shows beautiful TUI menu
- [x] Menu selections update `user-state.json`
- [x] User hooks execute correctly
- [x] Menu extensions work

---

## 📍 Phase 4: v0.4.0 - Languages & Services

**Goal**: Runtime languages, database services, and Docker databases.

### Checklist

- [x] **Language Modules (`modules/languages/`)**
  - [x] `modules/languages/ruby.nix`
  - [x] `modules/languages/python.nix`
  - [x] `modules/languages/node.nix`
  - [x] `modules/languages/rust.nix`

- [x] **Service Modules (`modules/services/`)**
  - [x] `modules/services/postgresql.nix`
  - [x] `modules/services/redis.nix`
  - [x] `modules/services/docker.nix`

- [x] **Docker Database Containers (inspired by `omarchy-install-docker-dbs`)**
  - [x] `caf-docker-db-install` - Interactive DB selection
  - [x] Support: MySQL, PostgreSQL, Redis, MongoDB, MariaDB
  - [x] Bound to localhost only
  - [x] Auto-restart on reboot

- [x] **CLI Integration**
  - [x] `caf install ruby` updates state and rebuilds
  - [x] `caf install postgresql` updates state and rebuilds

- [x] **Testing**
  - [x] `tests/modules/languages.nix`
  - [x] `tests/modules/services.nix`

### Success Criteria
- [x] `caf install ruby` → `ruby --version` works
- [x] PostgreSQL accepts connections
- [x] Docker daemon runs
- [x] `caf-docker-db-install` launches containers

---

## 📍 Phase 5: v0.5.0 - Frameworks

**Goal**: Framework stacks with auto-dependency resolution.

### Checklist

- [x] **Framework Modules (`modules/frameworks/`)**
  - [x] `modules/frameworks/rails.nix` - Auto-enables Ruby + PostgreSQL
  - [x] `modules/frameworks/django.nix` - Auto-enables Python + PostgreSQL
  - [x] `modules/frameworks/nextjs.nix` - Auto-enables Node

- [x] **Dependency Resolution**
  - [x] Framework enables required languages
  - [x] Framework enables required services

- [x] **CLI Integration**
  - [x] `caf install rails` shows dependency info
  - [x] Confirm before installing dependencies

- [x] **Testing**
  - [x] `tests/modules/frameworks.nix` (Includes Rails, Django, Next.js)

### Success Criteria
- [x] `caf install rails` installs Ruby + PostgreSQL + Rails
- [x] New Rails app can be created and runs

---

## 📍 Phase 6: v0.6.0 - Base Editors

**Goal**: Core editor installations and config management.

### Checklist

- [x] **Editor Modules (`modules/editors/`)**
  - [x] `modules/editors/neovim.nix`
  - [x] `modules/editors/helix.nix`
  - [x] `modules/editors/vscode-server.nix` - Bound to localhost (Tailscale via SSH tunnel)

- [x] **Default Configs (`config/editors/defaults/`)**
  - [x] `config/editors/defaults/nvim/init.lua`
  - [x] `config/editors/defaults/helix/config.toml`
  - [x] `config/editors/defaults/vscode/settings.json`

- [x] **Config Management CLI (inspired by `omarchy-refresh-config`)**
  - [x] `caf-config-init <editor>` - Initialize user config
  - [x] `caf-config-refresh <path>` - Reset with backup
  - [x] `caf-config-diff <editor>` - Show changes
  - [x] `caf-editor-launch` - Launch configured editor
  - [x] `caf-editor-set <editor>` - Set default editor

- [x] **Testing**
  - [x] `tests/modules/editors.nix` (Covers Neovim, Helix)

### Success Criteria
- [x] `nvim --version` works
- [x] VS Code Server accessible via browser (localhost:8080)
- [x] `caf-config-refresh` backs up and resets config

---

## 📍 Phase 7: v0.7.0 - Editor Distributions

**Goal**: Opinionated Neovim distributions with theme integration.

### Checklist

- [x] **Distribution Modules (`modules/editors/distributions/nvim/`)**
  - [x] `astronvim.nix` - Auto-enables neovim
  - [x] `lazyvim.nix`
  - [x] `nvchad.nix`
  - [x] `lunarvim.nix`

- [x] **Distribution Configs (`config/editors/distributions/nvim/`)**
  - [x] Full LazyVim config with Catppuccin
  - [x] Full AstroNvim config with Catppuccin
  - [x] Full NvChad config with Catppuccin
  - [x] Full LunarVim config with Catppuccin

- [x] **User Config Templates**
  - [x] `config/templates/editors/nvim/init.lua.tpl`
  - [x] `config/templates/editors/nvim/user/init.lua.tpl`

- [x] **Theme Integration**
  - [x] `config/themes/catppuccin/nvim.lua`

- [x] **CLI Integration**
  - [x] `caf-editor-distribution-set nvim <distribution>`
  - [x] `caf-nvim-distribution-setup` - Clones and configures
  - [x] Only one distribution active at a time

- [x] **Testing**
  - [x] `tests/modules/editors-distributions.nix`

### Success Criteria
- [x] `caf-editor-distribution-set nvim lazyvim` configures Neovim
- [x] `nvim` launches with distribution + Catppuccin
- [x] User overrides in `~/.config/nvim/lua/plugins/` work

---

## 📍 Phase 8: v0.8.0 - AI Integration

**Goal**: Local AI inference and coding assistants.

### Checklist

- [ ] **AI Modules (`modules/ai/`)**
  - [ ] `modules/ai/ollama.nix` - Systemd service, localhost only
  - [ ] `modules/ai/aider.nix` - AI pair programming
  - [ ] `modules/ai/continue.nix` - IDE extension support

- [ ] **Ollama Configuration**
  - [ ] Pre-download default model (codellama:7b)
  - [ ] ZRAM optimization

- [ ] **Secrets for External APIs**
  - [ ] Add API keys to `secrets/secrets.yaml`
  - [ ] `caf-ai-keys-manage`

- [ ] **Starship Integration**
  - [ ] Show active Ollama model in prompt
  - [ ] AI status indicator

- [ ] **Testing**
  - [ ] `tests/modules/ai/ollama.nix`
  - [ ] `tests/modules/ai/aider.nix`

### Success Criteria
- [ ] Ollama API responds
- [ ] Aider works with local models
- [ ] Starship shows AI model

---

## 📍 Phase 9: v0.9.0 - Operations & Polish

**Goal**: System diagnostics, help, and quality-of-life features.

### Checklist

- [ ] **Debug & Diagnostics (inspired by `omarchy-debug`, `omarchy-upload-log`)**
  - [ ] `caf-debug-collect` - Gather system info, journalctl, dmesg
  - [ ] `caf-debug-upload` - Upload to paste service (0x0.st)
  - [ ] `caf-debug-view` - View locally
  - [ ] Log upload options: `this-boot`, `last-boot`, `installed-packages`

- [ ] **System Doctor**
  - [ ] `caf-system-doctor` - Check health, suggest fixes
  - [ ] Verify services running
  - [ ] Check disk space
  - [ ] Verify Tailscale connected
  - [ ] Check NixOS generation health

- [ ] **Update Wrapper**
  - [ ] `caf-system-update` - `nix flake update && rebuild`
  - [ ] Show what will change
  - [ ] Remind about rollback
  - [ ] Run `caf-hook-run post-update`

- [ ] **Release Channels (inspired by `omarchy-channel-set`)**
  - [ ] `caf-channel-set [stable|rc|edge|dev]`
  - [ ] Channels use different git refs in flake inputs
  - [ ] Stable = master branch, Edge = latest, Dev = development

- [ ] **Timezone Selection (inspired by `omarchy-tz-select`)**
  - [ ] `caf-tz-select` - Interactive timezone picker with gum filter
  - [ ] NixOS declarative approach for persistence

- [ ] **Keybindings Cheatsheet (inspired by `omarchy-menu-keybindings`)**
  - [ ] `caf-keys-show` - Interactive keybindings reference
  - [ ] Zellij shortcuts
  - [ ] Neovim/editor shortcuts
  - [ ] CLI tool shortcuts

- [ ] **Branding Polish**
  - [ ] `caf-about-show` - System info display (fastfetch wrapper)
  - [ ] Polish ASCII logo
  - [ ] `caf-show-done` - Completion indicator
  - [ ] `caf-version` - Display current version
  - [ ] `caf-version-pkgs` - Show last update time

- [ ] **Testing**
  - [ ] `tests/cli/debug.nix`
  - [ ] `tests/cli/doctor.nix`

### Success Criteria
- [ ] `caf-debug-collect` generates useful log
- [ ] `caf-debug-upload` successfully uploads to 0x0.st
- [ ] `caf-system-doctor` reports health status
- [ ] `caf-keys-show` displays cheatsheet
- [ ] `caf-channel-set stable` switches channels
- [ ] `caf-system-update` runs smoothly with hooks

---

## 📍 Phase 10: v1.0.0 - Production Ready

**Goal**: First-run experience, install script, and documentation.

### Checklist

- [ ] **Install Script (`install.sh`)**
  - [ ] One-liner VPS bootstrap (nixos-anywhere)
  - [ ] Show ASCII logo during install
  - [ ] Tailscale auth key prompt
  - [ ] Progress indicators with gum

- [ ] **First-Run Wizard**
  - [ ] ASCII logo welcome
  - [ ] `caf setup` wizard
  - [ ] Choose editor, distribution, languages, AI
  - [ ] Apply and rebuild
  - [ ] Run `caf-hook-run first-run`

- [ ] **Documentation**
  - [ ] Comprehensive README with GIFs
  - [ ] `docs/` folder with guides
  - [ ] `CONTRIBUTING.md`
  - [ ] Keybindings reference doc

- [ ] **Security Audit**
  - [ ] Zero exposed ports (Tailscale only)
  - [ ] Validate sops-nix encryption
  - [ ] Review firewall rules

- [ ] **Integration Tests**
  - [ ] `tests/integration/full-rails-stack.nix`
  - [ ] `tests/integration/first-run-wizard.nix`

### Success Criteria
- [ ] Fresh VPS transformed with one command
- [ ] First-run wizard works smoothly
- [ ] Documentation complete
- [ ] Security review passes

---

## 🧪 Testing Protocol

Run `nix flake check` before every commit:

1. Verify Nix syntax
2. Boot VM for each test
3. Execute test assertions

### Test Naming Convention

Tests mirror source structure:
- `modules/editors/neovim.nix` → `tests/modules/editors/neovim.nix`
- `config/terminal/git/` → `tests/config/terminal/git/`

---

## 📚 Reference Materials

### Omarchy Repository: `../omarchy/`

| Category | Files to Study |
| :--- | :--- |
| **Menu System** | `bin/omarchy-menu` |
| **Config Refresh** | `bin/omarchy-refresh-config` |
| **Debug** | `bin/omarchy-debug` |
| **Hooks** | `bin/omarchy-hook`, `config/omarchy/hooks/*.sample` |
| **Extensions** | `config/omarchy/extensions/menu.sh` |
| **Dev Env** | `bin/omarchy-install-dev-env` |
| **Docker DBs** | `bin/omarchy-install-docker-dbs` |
| **Theme Templates** | `default/themed/*.tpl` |
| **Theme Apply** | `bin/omarchy-theme-set-templates` |
| **Show Utils** | `bin/omarchy-show-logo`, `bin/omarchy-show-done` |
| **Git Config** | `config/git/config` |
| **Fastfetch** | `config/fastfetch/config.jsonc` |
| **Btop** | `config/btop/btop.conf` |
| **Starship** | `config/starship.toml` |
| **Colors** | `themes/catppuccin/colors.toml` |
| **AGENTS.md** | Command naming conventions |
