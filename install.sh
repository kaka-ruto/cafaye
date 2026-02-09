#!/bin/bash
# Cafaye OS: VPS Installer
# Usage:
#   Interactive: ssh root@<vps-ip> && curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
#   Automated:    curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -s -- --yes

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

clone_cafaye() {
  if [[ -d /root/cafaye ]]; then
    log_info "Cafaye exists at /root/cafaye"
    cd /root/cafaye
  else
    log_info "Cloning Cafaye to /root/cafaye..."
    cd /root
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
    cd /root/cafaye
  fi
}

is_nixos_installer() {
  [[ -f /etc/NIXOS ]] || [[ -f /etc/NIXOS_LUSTRATION ]] || grep -qi "nixos" /proc/version 2>/dev/null
}

has_nix() {
  command -v nix &> /dev/null
}

detect_primary_disk() {
  # Try to find the first non-removable disk
  local disk=""
  disk=$(lsblk -dn -o NAME,TYPE,ROTA | grep "disk" | head -n1 | awk '{print "/dev/"$1}')
  
  if [[ -z "$disk" ]]; then
    # Fallback to a common default if detection fails
    disk="/dev/sda"
  fi
  echo "$disk"
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
  if [[ -f /etc/nix/nix.conf ]] && ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    log_info "Enabling experimental features..."
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
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

  # Stop nix services
  systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true

  # Remove nix build users
  for i in $(seq 1 32); do userdel "nixbld$i" 2>/dev/null || true; done
  groupdel nixbld 2>/dev/null || true

  # Remove cafaye
  rm -rf /root/cafaye 2>/dev/null || true

  # Remove nix directories
  rm -rf /nix /root/.nix /root/.config/nix /root/.cache/nix 2>/dev/null || true

  # Remove nix config and ALL backup files
  rm -rf /etc/nix 2>/dev/null || true
  rm -f /etc/profile.d/nix.sh /etc/profile.d/nix.sh.backup-before-nix 2>/dev/null || true
  rm -f /etc/bash.bashrc.backup-before-nix /etc/bashrc.backup-before-nix /etc/zshrc.backup-before-nix 2>/dev/null || true

  # Remove systemd units
  rm -f /etc/systemd/system/nix-daemon.service /etc/systemd/system/nix-daemon.socket 2>/dev/null || true
  rm -f /etc/systemd/system/sockets.target.wants/nix-daemon.socket 2>/dev/null || true
  rm -f /etc/tmpfiles.d/nix-daemon.conf 2>/dev/null || true

  # Clean shell configs
  for file in /etc/bash.bashrc /etc/bashrc /etc/zshrc /etc/profile; do
    if [[ -f "$file" ]]; then
      sed -i '/nix-daemon.sh/d' "$file" 2>/dev/null || true
      sed -i '/# Nix/,/# End Nix/d' "$file" 2>/dev/null || true
    fi
  done

  systemctl daemon-reload 2>/dev/null || true

  log "Cleanup complete!"
}

setup_ssh_for_localhost() {
  log_info "Setting up SSH for root@localhost..."
  
  # Generate SSH key if not exists
  if [[ ! -f /root/.ssh/id_ed25519 ]]; then
    mkdir -p /root/.ssh
    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -C "root@localhost" 2>/dev/null || true
  fi
  
  # Add key to authorized_keys
  cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys 2>/dev/null || true
  chmod 600 /root/.ssh/authorized_keys 2>/dev/null || true
  chmod 700 /root/.ssh 2>/dev/null || true
  
  # Enable root login and password auth temporarily
  if [[ -f /etc/ssh/sshd_config ]]; then
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
  fi
  
  log "SSH configured"
}

install_nixos() {
  log_info "Installing NixOS via nixos-anywhere..."

  enable_experimental_features
  source_nix

  # Install nixos-anywhere
  nix profile install github:nix-community/nixos-anywhere 2>/dev/null || true

  # Run nixos-anywhere with proper error handling
  if ! /root/.nix-profile/bin/nixos-anywhere --flake '.#cafaye' root@localhost; then
    log_error "nixos-anywhere failed. This is often due to disk space limitations in the installer."
    log_info "Falling back to manual installation method..."
    install_nixos_manual
  fi
}

install_nixos_manual() {
  log_info "Installing NixOS manually (fallback method)..."
  
  # Setup zram to avoid disk space issues
  log_info "Setting up zram for additional memory..."
  modprobe zram 2>/dev/null || true
  if [[ -e /sys/block/zram0 ]]; then
    echo 4G > /sys/block/zram0/disksize 2>/dev/null || true
    mkswap /dev/zram0 2>/dev/null || true
    swapon /dev/zram0 2>/dev/null || true
  fi
  
  # Clean up nix store to free space
  nix store gc 2>/dev/null || true
  
  # Mount disks
  log_info "Mounting disks..."
  mkdir -p /mnt
  mount /dev/sda1 /mnt
  mkdir -p /mnt/boot
  mount /dev/sda15 /mnt/boot
  
  # Install channel
  log_info "Installing NixOS channel..."
  nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
  nix-channel --update
  
  # Clone cafaye
  log_info "Cloning cafaye configuration..."
  mkdir -p /mnt/root
  cd /mnt/root
  curl -fsSL https://github.com/kaka-ruto/cafaye/archive/refs/heads/master.tar.gz -o /tmp/cafaye.tar.gz
  tar xzf /tmp/cafaye.tar.gz
  mv cafaye-master cafaye
  
  # Create minimal configuration
  log_info "Creating minimal NixOS configuration..."
  local disk=$(detect_primary_disk)
  cat > /mnt/etc/nixos/configuration.nix << EOF
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  
  boot.loader.grub = {
    enable = true;
    device = "$disk";
  };
  
  networking.hostName = "cafaye";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  
  users.users.root.initialPassword = "changeme";
  environment.systemPackages = with pkgs; [ git curl vim ];
  system.stateVersion = "24.05";
}
EOF
  
  # Generate hardware configuration
  nixos-generate-config --root /mnt
  
  # Install
  log_info "Running nixos-install (this will take 15-30 minutes)..."
  if ! nixos-install --root /mnt --no-root-passwd; then
    log_error "Installation failed. Check /tmp/nixos-install.log for details."
    log_info "You may need to retry or use a VPS with more RAM/disk space."
    log_info "See docs/VPS-INSTALL.md for troubleshooting."
    exit 1
  fi
  
  log "Installation complete! Rebooting..."
  sleep 5
  reboot
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
  setup_ssh_for_localhost
  clone_cafaye
  
  # Initialize state with detected hardware
  local disk=$(detect_primary_disk)
  log_info "Detected primary disk: $disk"
  
  if [[ ! -f user/user-state.json ]]; then
    log_info "Initializing user-state.json..."
    cp user/user-state.json.example user/user-state.json
    
    # Update disk and architecture in the local state for the installer
    sed -i "s|/dev/vda|$disk|" user/user-state.json
    sed -i "s|/dev/sda|$disk|" user/user-state.json
    
    # Capture current authorized keys if any
    if [[ -f /root/.ssh/authorized_keys ]]; then
       log_info "Migrating SSH keys to user state..."
       keys=$(cat /root/.ssh/authorized_keys | tr '\n' ',' | sed 's/,$//' | sed 's/,/","/g')
       sed -i "s|ssh-ed25519 YOUR_SSH_PUBLIC_KEY_HERE your@email.com|$keys|" user/user-state.json
    fi
  fi
  
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

  if is_nixos_installer; then
    log "Detected NixOS installer environment"
    clone_cafaye
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
    3) clone_cafaye ;;
  esac
}

main "$@"
