#!/bin/bash
# Cafaye OS: VPS Installer - Cleanup Module
# Handles detection and removal of existing installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[i]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*" >&2; }
log_ok() { echo -e "${GREEN}[✓]${NC} $*"; }

# Check if Nix command exists
has_nix() {
  command -v nix &> /dev/null
}

# Check if directory exists
has_dir() {
  [[ -d "$1" ]]
}

# Check if Nix build users exist
has_nix_users() {
  id nixbld1 &> /dev/null
}

# Show what will be deleted
show_deletion_preview() {
  echo -e "${CYAN}📋 The following will be DELETED:${NC}"
  echo ""

  if has_nix || has_dir /nix || has_nix_users; then
    echo "  🗑️  Nix package manager:"
    echo "      • /nix directory (all cached packages)"
    echo "      • Build users: nixbld1 through nixbld32"
    echo "      • Group: nixbld"
    echo "      • Configuration: /etc/nix/"
    echo "      • Shell configs: /etc/profile.d/nix.sh"
  fi

  if has_dir /root/cafaye; then
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
  if has_dir /root/cafaye; then
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

  log_ok "✅ System cleaned successfully!"
  echo ""
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

  if has_dir /nix; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix directory found at /nix"
  fi

  if has_dir /etc/nix; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix configuration found at /etc/nix"
  fi

  if has_nix_users; then
    found_any=true
    echo -e "${YELLOW}[!]${NC} Nix build users found"
  fi

  if has_dir /root/cafaye; then
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
