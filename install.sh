#!/bin/bash
# Cafaye OS: VPS Installer
set -e

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

check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
  fi
}

clone_installer_repo() {
  if [[ -d /root/cafaye ]]; then
    log_info "Cafaye exists at /root/cafaye"
  else
    log_info "Cloning Cafaye to /root/cafaye..."
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
  fi
}

is_nixos_installer() {
  [[ -f /etc/NIXOS_LUSTRATION ]] || grep -q "nixos" /proc/version 2>/dev/null
}

has_nix() {
  command -v nix &> /dev/null
}

ensure_curl() {
  if ! command -v curl &> /dev/null; then
    log_info "Installing curl..."
    apt-get update && apt-get install -y curl
  fi
}

source_nix() {
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi
}

enable_experimental_features() {
  if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    log_info "Enabling experimental features..."
    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
  fi
}

install_nix() {
  if has_nix; then
    log_info "Nix already installed, skipping..."
    return 0
  fi

  log_info "Installing Nix (multi-user)..."
  ensure_curl
  curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
  source_nix
  log "Nix installed successfully"
}

check_existing() {
  echo -e "${CYAN}🔍 Scanning for existing installations...${NC}"

  local found=false
  if has_nix || [[ -d /nix ]]; then
    found=true
    echo -e "${YELLOW}[!]${NC} Nix found"
  fi
  if [[ -d /root/cafaye ]]; then
    found=true
    echo -e "${YELLOW}[!]${NC} Cafaye found"
  fi

  if [[ "$found" == true ]]; then
    echo ""
    echo "⚠️  Previous installations detected!"
  else
    echo "✅ No existing installations found."
  fi
  echo ""
}

show_deletion_preview() {
  echo -e "${CYAN}📋 The following will be DELETED:${NC}"
  echo ""

  if has_nix || [[ -d /nix ]]; then
    echo "  🗑️  Nix package manager and all /nix data"
  fi
  if [[ -d /root/cafaye ]]; then
    echo "  🗑️  Cafaye at /root/cafaye"
  fi
  echo ""
}

cleanup_existing() {
  echo -e "${CYAN}🧹 Cleaning up...${NC}"

  if [[ -d /root/cafaye ]]; then
    rm -rf /root/cafaye
  fi

  if has_nix; then
    systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true
    for i in $(seq 1 32); do userdel "nixbld$i" 2>/dev/null || true; done
    groupdel nixbld 2>/dev/null || true
    rm -rf /nix /root/.nix /root/.config/nix /root/.cache/nix 2>/dev/null || true
    rm -rf /etc/nix /etc/profile.d/nix.sh 2>/dev/null || true
    rm -f /etc/bash.bashrc.backup-before-nix /etc/bashrc.backup-before-nix /etc/zshrc.backup-before-nix 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
  fi

  log "Cleanup complete!"
}

install_nixos() {
  log_info "Installing NixOS via nixos-anywhere..."

  enable_experimental_features
  source_nix

  cd /root/cafaye

  nix run \
    --option extra-experimental-features "nix-command flakes" \
    github:nix-community/nixos-anywhere -- \
    --flake ".#cafaye" \
    --kexec \
    --no-passwd \
    --no-bootloader \
    root@localhost
}

auto_install() {
  check_existing
  show_deletion_preview

  if [[ "$auto_yes" == true ]]; then
    log_info "Auto-confirming..."
    cleanup_existing
  else
    echo -e "${CYAN}Proceed with deletion and installation?${NC}"
    echo "  1. Yes"
    echo "  2. No"
    read -p "Choice: " choice
    echo ""
    if [[ "$choice" != "1" ]]; then
      echo "Cancelled."
      exit 0
    fi
    cleanup_existing
  fi

  install_nix
  install_nixos
}

main() {
  local auto_yes=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes) auto_yes=true; shift ;;
      *) shift ;;
    esac
  done

  check_root
  clone_installer_repo

  if is_nixos_installer; then
    log "Detected NixOS installer environment"
    install_nixos
    exit 0
  fi

  if [[ ! -t 0 ]] || [[ "$auto_yes" == true ]]; then
    auto_install
    exit 0
  fi

  echo -e "${CYAN}☕ Cafaye OS Installer${NC}"
  echo "1. Install NixOS"
  echo "2. Install Nix only"
  echo "3. Clone Cafaye"
  echo "4. Exit"
  read -p "Choice: " choice

  case "$choice" in
    1) auto_install ;;
    2) install_nix ;;
    3) clone_installer_repo ;;
  esac
}

main "$@"
