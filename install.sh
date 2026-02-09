#!/bin/bash
# Cafaye OS: VPS Installer
# Usage: Run this ON your VPS (after SSHing in)
#
#   ssh root@<your-vps-ip>
#   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $*"; }
log_info() { echo -e "${BLUE}[i]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*" >&2; }

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    echo "Run: sudo -i"
    exit 1
  fi
}

# Clone cafaye
clone_cafaye() {
  log_info "Cloning Cafaye..."

  if [[ -d /root/cafaye ]]; then
    log_info "Cafaye already exists, pulling latest..."
    cd /root/cafaye
    git pull origin master
  else
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
    cd /root/cafaye
  fi

  log "Cafaye ready"
}

# Install NixOS using nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  clone_cafaye

  cd /root/cafaye

  log_info "Running nixos-anywhere..."
  nix run github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost

  log "NixOS installation complete!"
}

# Detect if we're in NixOS installer
is_nixos_installer() {
  [[ -f /etc/NIXOS_LUSTRATION ]] || grep -q "nixos" /proc/version 2>/dev/null
}

# Main
main() {
  local auto_yes=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        auto_yes=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--yes]"
        exit 1
        ;;
    esac
  done

  echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
  echo -e "${YELLOW}========================${NC}"
  echo ""

  check_root

  if is_nixos_installer; then
    log "Detected NixOS installer environment"
    install_nixos
    exit 0
  fi

  log_info "This will:"
  echo "  1. Install Nix"
  echo "  2. Clone Cafaye"
  echo "  3. Install NixOS via kexec"
  echo ""
  log_warn "This will REPLACE your current OS with NixOS!"
  echo ""

  if [[ "$auto_yes" == true ]] || [[ ! -t 0 ]]; then
    REPLY="y"
    echo "Auto-confirming (non-interactive mode)..."
  else
    read -p "Continue? (y/N): " -n 1 -r
    echo
  fi

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
  fi

  install_nixos

  echo ""
  log "Installation complete!"
  echo ""
  echo "After reboot:"
  echo "  ssh root@<your-vps-ip>"
  echo "  caf-setup"
}

main "$@"
