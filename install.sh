#!/bin/bash
# Cafaye OS: Fully Automated VPS Installer
#
# Usage (from your machine):
#   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -- root@<vps-ip>
#
# This script:
# 1. SSHs into your VPS
# 2. Downloads and runs the installer ON the VPS
# 3. VPS converts to NixOS
# 4. Optionally runs caf-setup automatically after reboot
#
# Requirements:
# - Fresh VPS (Ubuntu 24.04 or Debian 12)
# - Root SSH access
# - SSH key (already configured)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[✓]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*" >&2; }

# Parse arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --user) SSH_USER="$2"; shift ;;
      --port) SSH_PORT="$2"; shift ;;
      --setup) AUTO_SETUP=true; shift ;;
      --help|-h)
        echo "Usage: curl ... | bash -- <user@host> [--port <port>] [--setup]"
        echo ""
        echo "Arguments:"
        echo "  <user@host>   SSH target (e.g., root@192.168.1.100)"
        echo "  --port        SSH port (default: 22)"
        echo "  --setup       Automatically run caf-setup after installation"
        exit 0
        ;;
      -*)
        log_error "Unknown option: $1"
        exit 1
        ;;
      *)
        SSH_TARGET="$1"
        ;;
    esac
    shift
  done
  
  SSH_USER="${SSH_USER:-root}"
  SSH_PORT="${SSH_PORT:-22}"
  AUTO_SETUP="${AUTO_SETUP:-false}"
  
  # Parse user@host
  if [[ "$SSH_TARGET" =~ ^([^@]+)@(.+)$ ]]; then
    SSH_USER="${BASH_REMATCH[1]:-$SSH_USER}"
    SSH_HOST="${BASH_REMATCH[2]}"
  elif [[ -n "$SSH_TARGET" ]]; then
    SSH_HOST="$SSH_TARGET"
  fi
}

# Check SSH connectivity
check_ssh() {
  log_info "Checking SSH connection to $SSH_USER@$SSH_HOST:$SSH_PORT..."
  
  if ssh -o BatchMode=yes \
         -o ConnectTimeout=10 \
         -o StrictHostKeyChecking=accept-new \
         -p "$SSH_PORT" \
         "$SSH_USER@$SSH_HOST" \
         "echo 'SSH OK'" 2>/dev/null; then
    log_success "SSH connection successful"
    return 0
  else
    log_error "Cannot connect to $SSH_USER@$SSH_HOST:$SSH_PORT"
    return 1
  fi
}

# Check VPS status
check_vps_status() {
  log_info "Checking VPS status..."
  
  local status
  status=$(ssh -o BatchMode=yes -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
    "test -f /etc/nixos/configuration.nix && echo 'nixos' || echo 'debian'")
  
  if [[ "$status" == "nixos" ]]; then
    log_success "VPS already has NixOS!"
    return 1
  fi
  
  log_info "VPS has $status - will install NixOS"
  return 0
}

# Run command on VPS
run_on_vps() {
  ssh -o BatchMode=yes -o ConnectTimeout=30 -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "$@"
}

# Install NixOS on VPS
install_on_vps() {
  log_info "Installing NixOS on $SSH_USER@$SSH_HOST..."
  
  # The full installer script to run on VPS
  local vps_installer='
set -e
echo "☕ Installing Cafaye OS..."
echo "Installing dependencies..."
apt-get update && apt-get install -y curl git sudo
echo "Downloading NixOS..."
curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
echo "Cloning Cafaye..."
git clone https://github.com/kaka-ruto/cafaye /root/cafaye
cd /root/cafaye
echo "Installing NixOS..."
nix --experimental-features "nix-command flakes" run github:nix-community/nixos-anywhere -- --flake .#cafaye --no-reboot
echo "Installation complete! Rebooting..."
reboot
'
  
  # Upload and execute
  echo "$vps_installer" | run_on_vps "bash"
  
  log_success "Installation initiated!"
  log_info "VPS will reboot into NixOS automatically"
}

# Wait for VPS to come back online
wait_for_reboot() {
  log_info "Waiting for VPS to reboot (this takes 1-2 minutes)..."
  
  local retries=30
  for i in $(seq 1 $retries); do
    if ssh -o BatchMode=yes -o ConnectTimeout=5 -p "$SSH_PORT" \
           -o StrictHostKeyChecking=no \
           "$SSH_USER@$SSH_HOST" "echo 'OK'" 2>/dev/null; then
      log_success "VPS is back online!"
      return 0
    fi
    echo -n "."
    sleep 5
  done
  
  log_warn "VPS did not come back online within timeout"
  return 1
}

# Run caf-setup on VPS
run_caf_setup() {
  if [[ "$AUTO_SETUP" != "true" ]]; then
    log_info "Skipping automatic caf-setup (use --setup flag to enable)"
    echo ""
    echo "To configure your system, SSH in and run:"
    echo "  ssh $SSH_USER@$SSH_HOST"
    echo "  caf-setup"
    return 0
  fi
  
  log_info "Running caf-setup on VPS..."
  
  # Wait a bit for system to stabilize
  sleep 10
  
  run_on_vps "caf-setup" || {
    log_warn "caf-setup failed or was cancelled"
    echo "You can run it manually:"
    echo "  ssh $SSH_USER@$SSH_HOST"
    echo "  caf-setup"
  }
}

# Main
main() {
  echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
  echo -e "${YELLOW}========================${NC}"
  echo ""
  
  parse_args "$@"
  
  if [[ -z "$SSH_HOST" ]]; then
    log_error "Missing SSH target"
    echo ""
    echo "Usage: curl ... | bash -- root@<vps-ip>"
    echo ""
    echo "Example:"
    echo "  curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -- root@192.168.1.100"
    exit 1
  fi
  
  # Check SSH
  check_ssh || exit 1
  
  # Check if already NixOS
  if ! check_vps_status; then
    run_caf_setup
    exit 0
  fi
  
  # Install NixOS on VPS
  install_on_vps
  
  # Wait for reboot
  wait_for_reboot
  
  # Run caf-setup if requested
  run_caf_setup
  
  echo ""
  log_success "Cafaye OS installation complete!"
}

main "$@"
