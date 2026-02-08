# Changelog

All notable changes to Cafaye OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.3] - 2026-02-08

### Added

- **Factory CI/CD Status Checker**: New `caf-factory-check` CLI command for monitoring CI/CD:
  - `--latest` - Show status of latest CI run
  - `--commit SHA` - Check specific commit status
  - `--logs` - Display actual error logs inline (no separate `gh` command needed)
  - `--watch` - Live monitoring mode (refreshes every 60 seconds)
  - `--in-progress` - Include currently running builds
  - `--failed-steps` - Show failed job details
  - `--run-id ID` - Check specific run by ID
  - Stores results in `.factory/` directory for local tracking

- **Local Testing Script**: New `./bin/test-local.sh` for fast pre-CI validation:
  - Nix flake evaluation check (~10 seconds)
  - Script syntax validation (bash)
  - User state JSON verification
  - Module import checks
  - Documentation completeness check
  - No VM boot required

- **Unified Test Suite**: Optimized testing with merged VM tests:
  - `core-unified.nix` - Tests boot, network, security in one VM
  - `cli-unified.nix` - Tests all CLI functionality in one VM
  - `modules-unified.nix` - Tests languages, services, editors, frameworks in one VM
  - Maintains individual tests in `individualChecks` for debugging

### Changed

- **CI/CD Optimization**: Faster, cleaner GitHub Actions workflow:
  - Removed Magic Nix Cache (was causing HTTP 418/500 errors)
  - Parallel test execution (core, cli, modules, integration)
  - Fast syntax check (~30 seconds vs 5 minutes previously)
  - Added timeout limits (3-15 minutes per job)
  - Matrix strategy for integration tests
  - Reduced VM boots from 14 to 4 per CI run (~70% faster)

- **Test Organization**: Clear separation of test types:
  - `checks` output: Unified tests for CI (fast)
  - `individualChecks` output: Individual tests for debugging
  - Flake check now evaluates in ~10 seconds

### Fixed

- Syntax errors in test files with proper conditional string closures
- GitHub Actions cache configuration errors
- Test file import paths for individual tests
- `.factory/` directory added to `.gitignore` for local CI tracking

### Changed
- **Tests**: Module and integration tests now respect user configuration.
  - Checks are skipped for disabled languages and frameworks.
  - Rails integration test no longer enforces Node.js presence if disabled.
- **Documentation**: Enhanced `README.md` with detailed VPS installation instructions.

### Fixed
- Fixed integration test failures with minimal configurations (e.g., Ruby/Rails only).
- Corrected permissions in first-run wizard test (`cafaye` user context).

## [0.9.1] - 2026-02-08

### Added

- `debug-vm` flake app for running QEMU VM directly.
- `dockerImage` package output for building Docker containers.
- Standalone CLI package definition.
- Devbox global installation instructions in README.
- Docker testing instructions in README and DEVELOPMENT.md.

## [0.9.0] - 2026-02-08

### Added

- **Installation & Setup**:
  - `install.sh`: Interactive VPS bootstrap script with ASCII branding and Tailscale support.
  - `caf-setup`: First-run wizard to configure editor, distro, languages, and AI.
  - `caf-hook-run`: Hook system for custom actions (e.g., `first-run`, `post-update`).

- **Documentation**:
  - `docs/INSTALL.md`: Setup guide.
  - `docs/FIRST_RUN.md`: Configuration guide.
  - `CONTRIBUTING.md`: Developer guidelines.

- **Testing**:
  - `tests/integration/first-run-wizard.nix`
  - `tests/integration/rails.nix` (Full Rails stack verification)

### Changed

- Renamed `tests/integration/full-rails-stack.nix` to `rails.nix`.
- Improved `caf-system-update` with non-interactive flag (`-y`).

## [0.8.0] - 2026-02-08

### Added
- **Debug & Diagnostics Suite** (inspired by omarchy):
  - `caf-debug-collect` - Comprehensive system info, journalctl, dmesg gathering
  - `caf-debug-upload` - Upload logs to 0x0.st (this-boot, last-boot, installed-packages)
  - `caf-debug-view` - View collected logs locally
- **System Doctor**:
  - `caf-system-doctor` - Health checks for NixOS generation, Tailscale, disk space, failed units, services
  - Actionable suggestions for common issues
- **Update Wrapper**:
  - `caf-system-update` - Flake update with dry-run preview and rollback reminder
  - Post-update hook support
- **Release Channels**:
  - `caf-channel-set` - Switch between stable, rc, edge, and dev channels
- **Timezone Selection**:
  - `caf-tz-select` - Interactive timezone picker with gum filter
- **Keybindings Cheatsheet**:
  - `caf-keys-show` - Interactive reference for Zellij, Neovim, Helix, and CLI shortcuts
- **Branding & Polish**:
  - `caf-about-show` - System info display with fastfetch
  - `caf-show-logo` - Cafaye ASCII logo display
  - `caf-show-done` - Completion indicator with spinner
  - `caf-version` - Display current version
  - `caf-version-pkgs` - Show last system update time
- **VM Tests**: `tests/cli/debug.nix`, `tests/cli/doctor.nix`

---

## [0.7.0] - 2026-02-08

### Added
- **Neovim Distribution System**: Support for popular opinionated Neovim configurations:
  - **LazyVim**: Modern plugin manager with curated defaults
  - **AstroNvim**: Feature-rich IDE-like experience
  - **NvChad**: Fast, beautiful, and extensible
  - **LunarVim**: IDE layer for Neovim
- **Distribution Configs**: Pre-configured starter templates with Catppuccin theming:
  - `config/editors/distributions/nvim/lazyvim/` - Full LazyVim setup
  - `config/editors/distributions/nvim/astronvim/` - AstroNvim user config
  - `config/editors/distributions/nvim/nvchad/` - NvChad chadrc.lua
  - `config/editors/distributions/nvim/lunarvim/` - LunarVim config.lua
- **Catppuccin Theme Integration**: Comprehensive `config/themes/catppuccin/nvim.lua` with full plugin integrations
- **User Config Templates**: `config/templates/editors/nvim/` for custom setups
- **CLI Utilities**:
  - `caf-editor-distribution-set` - Select and activate a distribution (mutual exclusion)
  - `caf-nvim-distribution-setup` - Clone starter template and apply theming
- **VM Tests**: `tests/modules/editors-distributions.nix` verifies distribution integration

---

## [0.6.0] - 2026-02-08

### Added
- **Editor Modules**: Declarative NixOS modules for core development editors:
  - **Neovim**: Full installation with build tools (gcc, make, tree-sitter, ripgrep, fd)
  - **Helix**: Modern modal editor with built-in LSP support
  - **VS Code Server**: Browser-based IDE via code-server, bound to localhost:8080
- **Default Configurations**: Sensible, Catppuccin-themed defaults for all editors:
  - `config/editors/defaults/nvim/init.lua` - Minimal Lua config with modern keymaps
  - `config/editors/defaults/helix/config.toml` - Catppuccin Mocha with auto-save
  - `config/editors/defaults/vscode/settings.json` - Developer-friendly VS Code settings
- **Config Management CLI** (inspired by `omarchy-refresh-config`):
  - `caf-config-init` - Initialize user config from defaults with backup
  - `caf-config-refresh` - Reset config with timestamped backup and diff
  - `caf-config-diff` - Compare user config against system defaults
  - `caf-editor-launch` - Launch the configured default editor
  - `caf-editor-set` - Set the default editor preference
- **VM Tests**: Automated verification of editor availability (`tests/modules/editors.nix`)

---

## [0.5.0] - 2026-02-08

### Added
- **Framework Modules**: Initial support for high-level application frameworks:
  - **Ruby on Rails**: Full system dependencies (libyaml, vips, pkg-config, etc.)
  - **Django**: Support for Python-based web applications with PostgreSQL and SQLite
  - **Next.js**: Optimized runtime for React-based fullstack developments
- **Auto-Dependency Wiring**: Intelligent logic that automatically enables required languages and services when a framework is selected (e.g., Rails → Ruby + PostgreSQL)
- **Enhanced CLI**: Interactive dependency alerts in the `caf` installer, informing users about the full stack being enabled
- **Integrated Framework Tests**: Comprehensive VM tests verifying cross-module dependency resolution

---

## [0.4.0] - 2026-02-08

### Added
- **Core Services**: Native NixOS modules for PostgreSQL 16 and Redis, pre-configured for security and local access
- **Docker DB Installer**: New `caf-docker-db-install` utility for one-click deployment of MySQL, MariaDB, MongoDB, and PostgreSQL containers
- **Language Modules**: Fully verified support for Ruby (with Bundler/Rake), Python (with Pip/Poetry), Node.js (with NPM/Yarn/PNPM), and Rust
- **CLI Submenu**: Dedicated `⚙️ Services` menu in the `caf` CLI for managing backend dependencies
- **Quality**: New VM test suites for service connectivity (`modules-services`) and application stacks

### Fixed
- Syntax error in `modules-services` test import paths
- Out-of-scope test references in `flake.nix`

---

## [0.3.0] - 2026-02-08

### Added
- **Caf CLI**: A flagship TUI management tool built with `bash` and `gum` for system administration
- **State Management**: Introduced `user-state.schema.json` for strict configuration validation
- **Core Utilities**: Standardized system helpers following the `caf-<thing>-<action>` pattern (e.g., `caf-state-read`, `caf-system-rebuild`)
- **Hook System**: Implemented `caf-hook-run` to allow user-defined scripts for `pre-update`, `post-update`, and `theme-set`
- **Extensibility**: Added support for user menu extensions in `~/.config/cafaye/extensions/`
- **Quality**: Dedicated VM tests for the CLI management layer and hook execution

### Fixed
- CI runner hanging during interactive shell tests by disabling Zellij auto-attach in test environments
- Missing `jq` and `git` dependencies in the system CLI module
- Hardcoded local paths in state management scripts to use system-standard `/etc/cafaye`

---

## [0.2.0] - 2026-02-08

### Added
- **Terminal Interface**: Complete Zsh configuration with Starship prompt and Oh My Zsh plugins
- **Workspace Management**: Zellij tiling multiplexer with auto-start and auto-attach logic
- **Essential Toolset**: Installed and configured `zoxide`, `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `btop`, `lazygit`, and `fastfetch`
- **Design System**: Global Catppuccin Mocha theme implemented across all terminal tools
- **Branding**: ASCII art logo and system details integration
- **Automation**: `direnv` and `nix-direnv` for automatic per-project environment loading
- **Compatibility**: Integrated `nix-ld` to support unpatched dynamic binaries (standard for IDE servers)
- **Quality**: Dedicated VM tests for terminal experience and tool availability

### Fixed
- SSH login flow to properly greet with system info and enter Zellij
- Catppuccin color consistency across different terminal emulators and tools

---

## [0.1.0] - 2026-02-07

### Added

- Initial project structure and documentation
- README.md with project vision
- DEVELOPMENT.md with 10-phase roadmap
- AGENTS.md with AI developer instructions
- Core system modules (boot, network, security, hardware)
- NixOS VM tests for core systems
- CI/CD workflow (The Factory) with Cachix integration
- Initial `install.sh` bootstrap script with auto-Nix installation
- JSON-based user state system (`user/user-state.json`)
- SOPS-nix encryption setup and secrets examples
- Tailscale auto-join service with encrypted auth keys
- Zero-trust security model (SSH only via Tailscale)
- Local "Full Test" runner with Docker support

### Changed
- Renamed system configuration from `cafaye-vps` to `cafaye`
- Standardized commit message format (no prefixes, natural language)
- Renamed main branch to `master`

### Fixed
- Infinite recursion error in flake evaluation for core modules
- Firewall service name check in security VM tests

---

## Version History

### Versioning Scheme

- **v0.x.0** - Pre-release development phases
- **v1.0.0** - First production-ready release
- **v1.x.x** - Stable releases with backwards compatibility

---

<!--
Template for new releases:

## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes
-->
