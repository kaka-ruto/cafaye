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

# Show welcome screen
show_welcome() {
  echo -e "${CYAN}☕ Cafaye OS Installer${NC}"
  echo -e "${CYAN}========================${NC}"
  echo ""
  echo "Welcome! This installer will set up NixOS on your VPS with:"
  echo "  • Nix package manager"
  echo "  • Cafaye OS configuration"
  echo "  • AI-first development environment"
  echo ""
}

# Check existing installations
check_existing() {
  echo -e "${CYAN}Checking for existing installations...${NC}"
  echo ""

  local has_nix=false
  local has_cafaye=false

  if has_command nix; then
    has_nix=true
    echo -e "${YELLOW}[!]${NC} Nix is already installed"
  fi

  if [[ -d /root/cafaye ]]; then
    has_cafaye=true
    echo -e "${YELLOW}[!]${NC} Cafaye directory already exists at /root/cafaye"
  fi

  echo ""
}

# Ask user about cleanup
ask_cleanup() {
  echo -e "${YELLOW}⚠️  Existing Installation Detected${NC}"
  echo ""
  echo "I found existing installations that may conflict:"
  echo ""

  if has_command nix; then
    echo "  • Nix package manager"
  fi

  if [[ -d /root/cafaye ]]; then
    echo "  • Cafaye at /root/cafaye"
  fi

  echo ""
  echo "To ensure a clean installation, I can remove these before proceeding."
  echo ""
  echo -e "${CYAN}Do you want to remove existing installations and start fresh?${NC}"
  echo ""
  echo "  1. Yes, clean everything and start fresh"
  echo "  2. No, keep existing installations"
  echo "  3. Cancel installation"
  echo ""

  read -p "Enter choice (1-3): " choice
  echo ""

  case "$choice" in
    1)
      cleanup_existing
      ;;
    2)
      log_info "Continuing with existing installations..."
      ;;
    3)
      echo "Installation cancelled."
      exit 0
      ;;
    *)
      log_error "Invalid choice: $choice"
      ask_cleanup
      ;;
  esac
}

# Clean up existing installations
cleanup_existing() {
  echo -e "${CYAN}Cleaning up existing installations...${NC}"
  echo ""

  if [[ -d /root/cafaye ]]; then
    log_info "Removing /root/cafaye..."
    rm -rf /root/cafaye
    log "Removed Cafaye directory"
  fi

  if has_command nix; then
    log_info "Removing Nix..."
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true
    fi
    nix-env -e '*' 2>/dev/null || true
    rm -rf /nix /root/.nix /root/.config/nix /root/.cache/nix 2>/dev/null || true
    userdel nixbld 2>/dev/null || true
    groupdel nixbld 2>/dev/null || true
    rm -rf /etc/nix /etc/profile.d/nix.sh /etc/bash.bashrc.backup-before-nix 2>/dev/null || true
    log "Removed Nix"
  fi

  if grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    log_info "Removing experimental-features from nix.conf..."
    sed -i '/experimental-features/d' /etc/nix/nix.conf 2>/dev/null || true
  fi

  log "Cleanup complete!"
  echo ""
}

# Install Nix
install_nix() {
  if has_command nix; then
    log "Nix is already installed, skipping..."
    return 0
  fi

  echo ""
  log_info "Installing Nix (multi-user)..."
  echo ""

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
    log_info "Cloning Cafaye..."
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
    cd /root/cafaye
  fi

  log "Cafaye ready"
}

# Enable experimental features
enable_experimental_features() {
  if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    log_info "Enabling experimental features (flakes, nix-command)..."
    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
  fi
}

# Install NixOS via nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  clone_cafaye

  cd /root/cafaye

  enable_experimental_features

  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi

  export NIX_CONFIG="experimental-features = nix-command flakes"

  log_info "Running nixos-anywhere..."
  log_info "This will kexec into NixOS installer and install the system."
  echo ""

  nix run github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost

  log "NixOS installation complete!"
}

# Show installation summary
show_summary() {
  echo ""
  echo -e "${CYAN}📋 Installation Summary${NC}"
  echo "====================="
  echo ""
  echo "This will:"
  echo "  1. Install Nix (multi-user)"
  echo "  2. Clone Cafaye repository"
  echo "  3. Run nixos-anywhere to install NixOS"
  echo "  4. Reboot into NixOS"
  echo ""
  echo -e "${YELLOW}⚠️  WARNING: This will REPLACE your current OS with NixOS!${NC}"
  echo ""
}

# Ask for final confirmation
ask_confirm() {
  echo -e "${CYAN}Ready to proceed?${NC}"
  echo ""
  echo "  1. Yes, install NixOS"
  echo "  2. Go back to main menu"
  echo "  3. Cancel"
  echo ""

  read -p "Enter choice (1-3): " choice
  echo ""

  case "$choice" in
    1)
      return 0
      ;;
    2)
      main_menu
      ;;
    3)
      echo "Installation cancelled."
      exit 0
      ;;
    *)
      log_error "Invalid choice: $choice"
      ask_confirm
      ;;
  esac
}

# Install NixOS via nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  clone_cafaye

  cd /root/cafaye

  enable_experimental_features

  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi

  log_info "Running nixos-anywhere..."
  log_info "This will kexec into NixOS installer and install the system."
  echo ""

  nix run github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost

  log "NixOS installation complete!"
}

# Show main menu
show_main_menu() {
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
      check_existing

      if has_command nix || [[ -d /root/cafaye ]]; then
        ask_cleanup
      fi

      show_summary
      ask_confirm

      install_nix
      install_nixos

      echo ""
      log "Installation complete!"
      echo ""
      echo "After reboot:"
      echo "  ssh root@<your-vps-ip>"
      echo "  caf-setup"
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

# Main menu loop
main_menu() {
  while true; do
    show_main_menu
    read -p "Enter choice (1-5): " choice
    echo ""
    handle_menu "$choice"
    echo ""
    echo "Press Enter to continue..."
    read
  done
}

# Detect if we're in NixOS installer
is_nixos_installer() {
  [[ -f /etc/NIXOS_LUSTRATION ]] || grep -q "nixos" /proc/version 2>/dev/null
}

# Main entry point
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
    check_existing

    if has_command nix || [[ -d /root/cafaye ]]; then
      cleanup_existing
    fi

    install_nix
    install_nixos
    exit 0
  fi

  show_welcome
  main_menu
}

main "$@"
