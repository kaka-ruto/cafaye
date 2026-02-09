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

# Detect if we're in NixOS installer
is_nixos_installer() {
  [[ -f /etc/NIXOS_LUSTRATION ]] || grep -q "nixos" /proc/version 2>/dev/null
}

# Clone installer repo and run from there
run_from_repo() {
  local temp_dir="/tmp/cafaye-install-$$"

  log_info "Preparing installer..."

  if [[ -d /root/cafaye ]]; then
    cd /root/cafaye
  else
    git clone https://github.com/kaka-ruto/cafaye "$temp_dir"
    cd "$temp_dir"
  fi

  # Source the modules
  source installer/cleanup.sh
  source installer/nix.sh
  source installer/cafaye.sh
  source installer/nixos.sh
  source installer/menu.sh

  # Run the actual installation
  run_installer
}

# Full NixOS installation
full_install() {
  log_info "Installing NixOS..."

  clone_or_update_cafaye
  cd_cafaye

  enable_experimental_features
  install_nixos

  echo ""
  log "Installation complete!"
  echo ""
  echo "After reboot:"
  echo "  ssh root@<your-vps-ip>"
  echo "  caf-setup"
}

# Automated installation (non-interactive)
auto_install() {
  check_existing

  if has_nix || has_dir /root/cafaye || has_dir /nix; then
    show_deletion_preview

    if [[ "$auto_yes" == true ]]; then
      log_info "Auto-confirming (--yes flag set)..."
      cleanup_existing
    else
      ask_proceed_deletion
      cleanup_existing
    fi
  fi

  install_nix
  full_install
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

      if has_nix || has_dir /root/cafaye || has_dir /nix; then
        show_deletion_preview
        ask_proceed_deletion
        cleanup_existing
      fi

      show_summary
      ask_confirm

      install_nix
      full_install
      ;;
    2)
      install_nix
      ;;
    3)
      clone_or_update_cafaye
      ;;
    4)
      if [[ -d /root/cafaye ]]; then
        cd_cafaye
        if command -v nix &> /dev/null; then
          source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" 2>/dev/null || true
        fi
        ./caf-setup
      else
        echo "Cafaye not found. Run option 3 first."
      fi
      ;;
    5)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid choice: $choice"
      ;;
  esac
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
      echo "Invalid choice: $choice"
      ask_confirm
      ;;
  esac
}

# Ask user to proceed with deletion
ask_proceed_deletion() {
  echo -e "${CYAN}Do you want to proceed with deletion and installation?${NC}"
  echo ""
  echo "  1. Yes, delete everything and install NixOS"
  echo "  2. No, cancel"
  echo ""

  read -p "Enter choice (1-2): " choice
  echo ""

  if [[ "$choice" != "1" ]]; then
    echo "Installation cancelled."
    exit 0
  fi
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

# Interactive installation
interactive_install() {
  show_welcome
  main_menu
}

# Check if Nix is installed
has_nix() {
  command -v nix &> /dev/null
}

# Clone or update Cafaye
clone_or_update_cafaye() {
  if [[ -d /root/cafaye ]]; then
    log_info "Cafaye already exists, pulling latest..."
    cd /root/cafaye
    git pull origin master
  else
    log_info "Cloning Cafaye..."
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
    cd /root/cafaye
  fi
}

# Change to cafaye directory
cd_cafaye() {
  cd /root/cafaye
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
  log "Nix installed successfully"
}

# Install NixOS using nixos-anywhere
install_nixos() {
  log_info "Installing NixOS..."

  source_nix

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
}

# Check for existing installations
check_existing() {
  echo -e "${CYAN}🔍 Scanning for existing installations...${NC}"
  echo ""

  local found_any=false

  if has_nix; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix command found"
  fi

  if [[ -d /nix ]]; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix directory found at /nix"
  fi

  if [[ -d /etc/nix ]]; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix configuration found at /etc/nix"
  fi

  if id nixbld1 &>/dev/null; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix build users found"
  fi

  if [[ -d /root/cafaye ]]; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Cafaye directory found at /root/cafaye"
  fi

  if [[ "$found_any" == true ]]; then
    echo ""
    echo "⚠️  Previous installations detected!"
    echo ""
    echo "A clean installation requires removing all existing Nix/Cafaye files."
    echo "This prevents conflicts and ensures a working system."
  else
    echo "✅ No existing installations found."
  fi

  echo ""
}

# Show what will be deleted
show_deletion_preview() {
  echo -e "${CYAN}📋 The following will be DELETED:${NC}"
  echo ""

  if has_nix || [[ -d /nix ]]; then
    echo "  🗑️  Nix package manager:"
    echo "      • /nix directory (all cached packages)"
    echo "      • Build users: nixbld1 through nixbld32"
    echo "      • Group: nixbld"
    echo "      • Configuration: /etc/nix/"
    echo "      • Shell configs: /etc/profile.d/nix.sh"
  fi

  if [[ -d /root/cafaye ]]; then
    echo ""
    echo "  🗑️  Cafaye:"
    echo "      • /root/cafaye directory"
  fi

  echo ""
}

# Stop and disable nix-daemon services
stop_nix_services() {
  log_info "Stopping Nix daemon services..."
  systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true
  systemctl disable nix-daemon.socket nix-daemon.service 2>/dev/null || true
}

# Remove Nix build users
remove_nix_users() {
  log_info "Removing Nix build users..."
  for i in $(seq 1 32); do
    userdel "nixbld$i" 2>/dev/null || true
  done
}

# Remove Nix build group
remove_nix_group() {
  log_info "Removing Nix build group..."
  groupdel nixbld 2>/dev/null || true
}

# Remove Nix directories
remove_nix_dirs() {
  log_info "Removing Nix directories..."
  rm -rf /nix 2>/dev/null || true
  rm -rf /root/.nix 2>/dev/null || true
  rm -rf /root/.config/nix 2>/dev/null || true
  rm -rf /root/.cache/nix 2>/dev/null || true
  rm -rf /home/*/.nix 2>/dev/null || true
  rm -rf /home/*/.config/nix 2>/dev/null || true
  rm -rf /home/*/.cache/nix 2>/dev/null || true
}

# Remove Nix configuration
remove_nix_config() {
  log_info "Removing Nix configuration..."
  rm -rf /etc/nix 2>/dev/null || true
  rm -f /etc/profile.d/nix.sh 2>/dev/null || true
}

# Clean up shell configurations
cleanup_shell_configs() {
  log_info "Cleaning up shell configurations..."

  for file in /etc/bash.bashrc /etc/bashrc /etc/zshrc /etc/profile; do
    if [[ -f "$file" ]]; then
      sed -i '/nix-daemon.sh/d' "$file" 2>/dev/null || true
      sed -i '/# Nix/,/# End Nix/d' "$file" 2>/dev/null || true
    fi
  done

  rm -f /etc/bash.bashrc.backup-before-nix 2>/dev/null || true
  rm -f /etc/bashrc.backup-before-nix 2>/dev/null || true
  rm -f /etc/zshrc.backup-before-nix 2>/dev/null || true
}

# Remove Cafaye
remove_cafaye() {
  if [[ -d /root/cafaye ]]; then
    log_info "Removing Cafaye directory..."
    rm -rf /root/cafaye
  fi
}

# Clean nix profiles
clean_nix_profiles() {
  log_info "Cleaning Nix profiles..."
  rm -rf /nix/var/nix/profiles 2>/dev/null || true
  rm -rf /nix/var/nix/gcroots 2>/dev/null || true
  rm -rf /nix/var/nix/db 2>/dev/null || true
}

# Remove systemd units
remove_systemd_units() {
  log_info "Removing systemd units..."
  rm -f /etc/systemd/system/nix-daemon.service 2>/dev/null || true
  rm -f /etc/systemd/system/nix-daemon.socket 2>/dev/null || true
  rm -f /etc/systemd/system/sockets.target.wants/nix-daemon.socket 2>/dev/null || true
  rm -f /etc/tmpfiles.d/nix-daemon.conf 2>/dev/null || true
  systemctl daemon-reload 2>/dev/null || true
}

# Main cleanup function
cleanup_existing() {
  echo -e "${CYAN}🧹 Wiping clean for fresh installation...${NC}"
  echo ""

  stop_nix_services
  remove_nix_users
  remove_nix_group
  remove_nix_dirs
  remove_nix_config
  cleanup_shell_configs
  remove_cafaye
  clean_nix_profiles
  remove_systemd_units

  log "✅ System cleaned successfully!"
  echo ""
}

# Main installer logic
run_installer() {
  if is_nixos_installer; then
    echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
    echo -e "${YELLOW}========================${NC}"
    echo ""
    log "Detected NixOS installer environment"
    full_install
    exit 0
  fi

  if [[ ! -t 0 ]] || [[ "$auto_yes" == true ]]; then
    auto_install
    exit 0
  fi

  interactive_install
}

# Main entry point
main() {
  auto_yes=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        auto_yes=true
        shift
        ;;
      --help|-h)
        echo "Cafaye OS Installer"
        echo ""
        echo "Usage:"
        echo "  Interactive: curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash"
        echo "  Automated:   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -s -- --yes"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--yes]"
        exit 1
        ;;
    esac
  done

  check_root
  run_installer
}

main "$@"
