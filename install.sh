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

# Install kexec-tools if missing
install_kexec() {
  log_info "Installing kexec-tools..."
  apt-get update && apt-get install -y kexec-tools
}

# Download NixOS installer kernel and initrd
download_nixos_installer() {
  log_info "Downloading NixOS installer..."

  local nixos_version="25.05"
  local kernel_url="https://channels.nixos.org/nixos-${nixos_version}/nixos-system-x86_64-linux-${nixos_version}.581.1a69d6f967df"
  local initrd_url="https://channels.nixos.org/nixos-${nixos_version}/nixos-initrd-x86_64-linux-${nixos_version}.581.1a69d6f967df"

  cd /tmp

  log_info "Downloading kernel..."
  curl -fSL "$kernel_url" -o kernel
  chmod +x kernel

  log_info "Downloading initrd..."
  curl -fSL "$initrd_url" -o initrd
  chmod +x initrd

  log "NixOS installer files downloaded"
}

# Kexec into NixOS installer
kexec_nixos() {
  log_info "Loading NixOS installer into memory..."

  local current_kernel=$(uname -r)
  local initrd_path="/tmp/initrd"
  local kernel_path="/tmp/kernel"

  kexec -l "$kernel_path" \
    --initrd="$initrd_path" \
    --append="init=/nix/store/*/initrd loglevel=4"

  log "Kernel loaded. Ready to reboot into NixOS installer."
  echo ""
  log_warn "System will reboot in 5 seconds..."
  sleep 5

  kexec -e
}

# Generate hardware configuration (runs after kexec reboot)
generate_hardware() {
  log_info "Generating hardware configuration..."

  nix --experimental-features "nix-command flakes" run github:nix-community/nixos-anywhere -- \
    generate-hardware-configuration /root/cafaye --flake /root/cafaye

  log "Hardware configuration generated"
}

# Install NixOS (runs after kexec reboot)
install_nixos() {
  log_info "Installing NixOS..."

  cd /root/cafaye

  nixos-install --flake ".#cafaye" --no-root-password

  log "NixOS installed successfully!"
  log "Your VPS will reboot into NixOS"
}

# Main installation flow for Ubuntu/Debian
install_via_kexec() {
  echo ""
  log_info "This will:"
  echo "  1. Install kexec-tools"
  echo "  2. Download NixOS installer kernel"
  echo "  3. Reboot into NixOS installer"
  echo "  4. Install NixOS"
  echo ""
  log_warn "IMPORTANT: This will reboot your system!"
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
  install_kexec
  download_nixos_installer
  kexec_nixos
}

# Post-kexec setup (runs after VPS reboots into NixOS installer)
setup_nixos() {
  echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
  echo -e "${YELLOW}========================${NC}"
  echo ""

  log "Running in NixOS installer environment"

  clone_cafaye
  generate_hardware
  install_nixos

  echo ""
  log "Installation complete!"
  echo ""
  echo "After reboot:"
  echo "  ssh root@<your-vps-ip>"
  echo "  caf-setup"
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

  check_root

  local os
  os=$(detect_os)

  if is_nixos_installer; then
    setup_nixos
    exit 0
  fi

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

  install_via_kexec
}

main "$@"
