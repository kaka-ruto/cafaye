# Changelog

All notable changes to Cafaye OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
