#!/bin/bash
# Cafaye OS: VPS Installer
# Usage:
#   Interactive: ssh root@<vps-ip> && curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
#   Automated:    curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -s -- --yes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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

# Check if command exists
has_command() {
  command -v "$1" &> /dev/null
}

# Install Nix
install_nix() {
  if has_command nix; then
    log "Nix is already installed"
    return 0
  fi

  log_info "Installing Nix (multi-user)..."

  if ! has_command curl; then
    apt-get update && apt-get install -y curl
  fi

  curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon

  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi

  log "Nix installed successfully"
}

# Clone cafaye
clone_cafaye() {
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

# Install NixOS via nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  clone_cafaye

  cd /root/cafaye

  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi

  log_info "Running nixos-anywhere (this will kexec into NixOS installer)..."
  log_info "The installer will download NixOS files and reboot into them..."

  nix --extra-experimental-features "nix-command flakes" run github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost

  log "NixOS installation complete!"
}

# Show interactive menu
show_menu() {
  echo -e "${CYAN}☕ Cafaye OS Installer${NC}"
  echo -e "${CYAN}========================${NC}"
  echo ""
  echo "What would you like to do?"
  echo ""
  echo "  1. Install NixOS (full system)"
  echo "  2. Install Nix only"
  echo "  3. Clone Cafaye repository"
  echo "  4. Run caf-setup"
  echo "  5. Exit"
  echo ""
}

# Handle menu choice
handle_menu() {
  local choice=$1

  case "$choice" in
    1)
      echo ""
      log_info "Selected: Install NixOS (full system)"
      echo ""
      log_warn "This will REPLACE your current OS with NixOS!"
      echo ""
      read -p "Continue? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_nix
        install_nixos
      else
        echo "Cancelled"
      fi
      ;;
    2)
      install_nix
      ;;
    3)
      clone_cafaye
      ;;
    4)
      if [[ -d /root/cafaye ]]; then
        cd /root/cafaye
        if has_command nix; then
          source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" 2>/dev/null || true
        fi
        ./caf-setup
      else
        log_error "Cafaye not found. Run option 3 first."
      fi
      ;;
    5)
      echo "Exiting..."
      exit 0
      ;;
    *)
      log_error "Invalid choice: $choice"
      ;;
  esac
}

# Detect if we're in NixOS installer
is_nixos_installer() {
  [[ -f /etc/NIXOS_LUSTRATION ]] || grep -q "nixos" /proc/version 2>/dev/null
}

# Main
main() {
  local auto_yes=false
  local install_only=false

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

  check_root

  if is_nixos_installer; then
    echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
    echo -e "${YELLOW}========================${NC}"
    echo ""
    log "Detected NixOS installer environment"
    install_nixos
    exit 0
  fi

  if [[ ! -t 0 ]] || [[ "$auto_yes" == true ]]; then
    install_nix
    install_nixos
    exit 0
  fi

  while true; do
    show_menu
    read -p "Enter choice (1-5): " choice
    echo ""
    handle_menu "$choice"
    echo ""
    echo "Press Enter to continue..."
    read
  done
}

main "$@"
