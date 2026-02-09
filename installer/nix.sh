#!/bin/bash
# Cafaye OS: VPS Installer - Nix Installation Module

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[i]${NC} $*"; }
log_ok() { echo -e "${GREEN}[✓]${NC} $*"; }

# Check if Nix is installed
has_nix() {
  command -v nix &> /dev/null
}

# Install curl if missing
ensure_curl() {
  if ! command -v curl &> /dev/null; then
    log_info "Installing curl..."
    apt-get update && apt-get install -y curl
  fi
}

# Source Nix profile
source_nix() {
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi
}

# Enable experimental features
enable_experimental_features() {
  if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    log_info "Enabling experimental features (flakes, nix-command)..."
    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
  fi
}

# Install Nix (multi-user)
install_nix() {
  if has_nix; then
    log_info "Nix is already installed, skipping..."
    return 0
  fi

  echo ""
  log_info "Installing Nix (multi-user)..."
  echo ""

  ensure_curl
  curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon

  source_nix
  log_ok "Nix installed successfully"
}
