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

# Detect OS
detect_os() {
  if [[ -f /etc/nixos ]]; then
    echo "nixos"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  elif [[ -f /etc/redhat-release ]]; then
    echo "rhel"
  else
    echo "unknown"
  fi
}

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    echo "Run: sudo -i"
    exit 1
  fi
}

# Install Nix (multi-user)
install_nix() {
  log_info "Installing Nix (multi-user)..."
  
  # Install curl if missing
  if ! command -v curl &> /dev/null; then
    log_info "Installing curl..."
    apt-get update && apt-get install -y curl
  fi
  
  # Run nix installer
  curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
  
  # Source nix
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi
  
  log "Nix installed successfully"
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

# Generate hardware configuration
generate_hardware() {
  log_info "Generating hardware configuration..."
  
  nix --experimental-features "nix-command flakes" run github:nix-community/nixos-anywhere -- generate-hardware-configuration /root/cafaye --flake /root/cafaye
}

# Install NixOS
install_nixos() {
  log_info "Installing NixOS..."
  
  cd /root/cafaye
  
  # Run nixos-install
  nixos-install --flake ".#cafaye" --no-root-password
  
  log "NixOS installed successfully!"
  log "Your VPS will reboot into NixOS"
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

  local os
  os=$(detect_os)

  case "$os" in
    nixos)
      log "Already running NixOS!"
      echo ""
      echo "To configure: cd /root/cafaye && ./caf-setup"
      exit 0
      ;;
    debian)
      log "Detected Debian/Ubuntu"
      ;;
    rhel)
      log "Detected RHEL/CentOS"
      log_warn "RHEL support is experimental"
      ;;
    *)
      log_error "Unsupported OS: $os"
      echo "This script supports: Debian, Ubuntu, NixOS"
      exit 1
      ;;
  esac

  echo ""
  log_info "This will:"
  echo "  1. Install Nix (multi-user)"
  echo "  2. Clone Cafaye"
  echo "  3. Install NixOS"
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

  echo ""
  install_nix
  clone_cafaye
  install_nixos

  echo ""
  log "Installation complete!"
  echo ""
  echo "After reboot:"
  echo "  ssh root@<your-vps-ip>"
  echo "  caf-setup"
}

main "$@"
