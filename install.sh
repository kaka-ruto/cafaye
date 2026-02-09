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

# Get directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source installer modules
source "$SCRIPT_DIR/installer/cleanup.sh"
source "$SCRIPT_DIR/installer/nix.sh"
source "$SCRIPT_DIR/installer/cafaye.sh"
source "$SCRIPT_DIR/installer/nixos.sh"
source "$SCRIPT_DIR/installer/menu.sh"

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

# Interactive installation
interactive_install() {
  show_welcome
  main_menu
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

main "$@"
