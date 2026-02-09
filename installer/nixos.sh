#!/bin/bash
# Cafaye OS: VPS Installer - NixOS Installation Module

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[i]${NC} $*"; }
log_ok() { echo -e "${GREEN}[✓]${NC} $*"; }

# Install NixOS using nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  # Source nix if available
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi

  log_info "Running nixos-anywhere..."
  log_info "This will kexec into NixOS installer and install the system."
  echo ""

  nix run \
    --option extra-experimental-features "nix-command flakes" \
    github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost

  log_ok "NixOS installation complete!"
}
