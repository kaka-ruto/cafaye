#!/bin/bash
# Cafaye OS: One-Line VPS Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
#
# This script:
# 1. Runs on YOUR machine (not the VPS)
# 2. Installs required dependencies (nix, nixos-anywhere, ssh, etc.)
# 3. Deploys NixOS to your VPS
#
# Requirements:
# - A fresh VPS (Ubuntu 24.04 or Debian 12)
# - At least 2GB RAM (1GB works with ZRAM)
# - Root SSH access
# - Your machine: macOS or Linux

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect if running from pipe
is_pipe_mode() {
  [[ -z "${BASH_SOURCE[0]}" ]]
}

# Get directory where this script is located
get_script_dir() {
  if is_pipe_mode; then
    pwd
  else
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
  fi
}

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Check if command exists
has_command() {
  command -v "$1" &> /dev/null
}

# Install Nix on user's machine
install_nix() {
  log_info "Installing Nix..."
  
  if has_command nix; then
    log_success "Nix is already installed"
    return 0
  fi
  
  # Check for macOS vs Linux
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS - recommend Nix installer
    log_warn "macOS detected. Installing Nix requires the Nix installer."
    log_info "Downloading Nix installer..."
    
    curl -fsSL https://nixos.org/nix/install | sh
    
    # Source nix
    if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
      source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
  else
    # Linux - try nix-installer or single-user install
    if has_command systemctl; then
      # Try nix-installer first (recommended for multi-user)
      log_info "Installing Nix (multi-user)..."
      curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
    else
      # Single-user install
      log_info "Installing Nix (single-user)..."
      curl -fsSL https://nixos.org/nix/install | sh
    fi
    
    # Source nix
    if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
      source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
  fi
  
  if has_command nix; then
    log_success "Nix installed successfully"
  else
    log_error "Failed to install Nix"
    return 1
  fi
}

# Install nixos-anywhere
install_nixos_anywhere() {
  log_info "Installing nixos-anywhere..."
  
  if ! has_command nix; then
    log_error "Nix is not installed. Cannot install nixos-anywhere."
    return 1
  fi
  
  # Install via nix
  nix --experimental-features "nix-command flakes" profile install github:nix-community/nixos-anywhere --extra-experimental-features "nix-command flakes"
  
  if has_command nixos-anywhere; then
    log_success "nixos-anywhere installed successfully"
  else
    log_error "Failed to install nixos-anywhere"
    return 1
  fi
}

# Install required tools on user's machine
install_dependencies() {
  log_info "Checking dependencies..."
  
  local missing=()
  
  # Essential tools
  for cmd in curl git ssh; do
    if ! has_command "$cmd"; then
      missing+=("$cmd")
    fi
  done
  
  if [[ ${#missing[@]} -gt 0 ]]; then
    log_warn "Missing tools: ${missing[*]}"
    
    # Try to install based on OS
    if [[ "$(uname)" == "Darwin" ]]; then
      log_info "Install with: brew install ${missing[*]}"
      if has_command brew; then
        brew install "${missing[@]}"
      fi
    elif [[ -f /etc/debian_version ]]; then
      log_info "Installing with apt..."
      sudo apt-get update && sudo apt-get install -y "${missing[@]}"
    elif [[ -f /etc/redhat-release ]]; then
      log_info "Installing with dnf/yum..."
      sudo dnf install -y "${missing[@]}" || sudo yum install -y "${missing[@]}"
    fi
  fi
  
  # Install Nix if needed
  install_nix || true
  
  # Install nixos-anywhere
  install_nixos_anywhere || true
  
  log_success "All dependencies ready"
}

# Gather VPS information
gather_vps_info() {
  echo ""
  echo -e "${GREEN}☕ Cafaye OS Installer${NC}"
  echo -e "${YELLOW}=============================${NC}"
  echo ""
  
  # VPS IP
  echo -e "${BLUE}VPS Connection Details${NC}"
  
  if [[ -z "$TARGET_IP" ]]; then
    echo -n "VPS IP address: "
    read -r TARGET_IP
  fi
  
  if [[ -z "$TARGET_USER" ]]; then
    echo -n "SSH user [root]: "
    read -r TARGET_USER
    TARGET_USER=${TARGET_USER:-root}
  fi
  
  if [[ -z "$SSH_PORT" ]]; then
    echo -n "SSH port [22]: "
    read -r SSH_PORT
    SSH_PORT=${SSH_PORT:-22}
  fi
  
  # SSH Key
  echo ""
  echo -e "${BLUE}SSH Key${NC}"
  echo "How would you like to provide your SSH key?"
  echo "1) Use keys from SSH agent"
  echo "2) Read from file (~/.ssh/id_ed25519, ~/.ssh/id_rsa)"
  echo "3) Paste manually"
  echo ""
  echo -n "Choose [1]: "
  read -r SSH_KEY_CHOICE
  SSH_KEY_CHOICE=${SSH_KEY_CHOICE:-1}
  
  case "$SSH_KEY_CHOICE" in
    1)
      if has_command ssh-add; then
        SSH_KEY=$(ssh-add -L 2>/dev/null || echo "")
        if [[ -z "$SSH_KEY" ]]; then
          log_warn "No keys in SSH agent. Trying file..."
          SSH_KEY_CHOICE=2
        fi
      else
        log_warn "ssh-add not available. Trying file..."
        SSH_KEY_CHOICE=2
      fi
      ;;
    2)
      local key_file=""
      for f in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
        if [[ -f "$f" ]]; then
          key_file="$f"
          break
        fi
      done
      
      if [[ -z "$key_file" ]]; then
        echo -n "Path to private key: "
        read -r key_file
      fi
      
      if [[ -f "$key_file" ]]; then
        SSH_KEY=$(cat "$key_file")
      else
        log_error "Key file not found: $key_file"
        exit 1
      fi
      ;;
    3)
      echo "Paste your private key (press Ctrl+D when done):"
      SSH_KEY=$(cat)
      ;;
  esac
  
  # Tailscale (optional)
  echo ""
  echo -e "${BLUE}TailScale (Optional)${NC}"
  echo "TailScale provides secure, zero-trust access to your server."
  echo ""
  echo -n "Do you want to configure TailScale? (y/N): "
  read -r CONFIGURE_TAILSCALE
  CONFIGURE_TAILSCALE=${CONFIGURE_TAILSCALE:-n}
  
  if [[ "$CONFIGURE_TAILSCALE" =~ ^[Yy]$ ]]; then
    echo -n "TailScale auth key (tskey-auth-...): "
    read -r TAILSCALE_AUTH_KEY
  fi
}

# Validate connectivity to VPS
validate_connection() {
  log_info "Validating SSH connection to $TARGET_USER@$TARGET_IP:$SSH_PORT..."
  
  if ssh -o BatchMode=yes \
         -o ConnectTimeout=10 \
         -p "$SSH_PORT" \
         "$TARGET_USER@$TARGET_IP" \
         "echo 'SSH connection successful'" 2>/dev/null; then
    log_success "SSH connection successful"
  else
    log_error "Cannot connect to $TARGET_USER@$TARGET_IP:$SSH_PORT"
    log_error "Please verify:"
    echo "  - VPS is running"
    echo "  - SSH port is correct ($SSH_PORT)"
    echo "  - IP address is correct ($TARGET_IP)"
    echo "  - Firewall allows SSH"
    exit 1
  fi
}

# Run nixos-anywhere to deploy
deploy_nixos() {
  local script_dir
  script_dir=$(get_script_dir)
  
  log_info "Deploying NixOS to $TARGET_USER@$TARGET_IP..."
  
  # Build the flake
  log_info "Building NixOS configuration..."
  cd "$script_dir"
  
  # Generate SSH key file temporarily
  local key_file
  key_file=$(mktemp)
  echo "$SSH_KEY" > "$key_file"
  chmod 600 "$key_file"
  
  # Run nixos-anywhere
  nixos-anywhere \
    --flake ".#cafaye" \
    --to "ssh://$TARGET_USER@$TARGET_IP:$SSH_PORT" \
    --ssh-key "$key_file" \
    --no-reboot \
    --kexec "https://github.com/nix-community/nixos-anywhere/releases/download/2024.11.06/kexec.x86_64-linux.tar.xz" \
    --extra-files "$script_dir" \
    2>&1 | tee /tmp/cafaye-install.log
  
  local exit_code=${PIPESTATUS[0]}
  
  # Clean up key file
  rm -f "$key_file"
  
  if [[ $exit_code -eq 0 ]]; then
    log_success "NixOS deployed successfully!"
    log_info "Server will reboot into NixOS..."
  else
    log_error "Deployment failed. See /tmp/cafaye-install.log for details."
    exit 1
  fi
}

# Post-installation
post_install() {
  echo ""
  log_success "Installation complete!"
  echo ""
  echo "Next steps:"
  echo "1. Wait for your server to reboot (1-2 minutes)"
  echo "2. SSH into your new NixOS server:"
  echo "   ssh $TARGET_USER@$TARGET_IP"
  echo "3. Run the setup wizard:"
  echo "   caf-setup"
  echo ""
  
  if [[ "$CONFIGURE_TAILSCALE" =~ ^[Yy]$ ]] && [[ -n "$TAILSCALE_AUTH_KEY" ]]; then
    echo "TailScale will be configured automatically on first boot."
  fi
  
  log_info "For issues, see /tmp/cafaye-install.log"
}

# Main
main() {
  # Install dependencies first
  install_dependencies
  
  # Gather info
  gather_vps_info
  
  # Validate
  validate_connection
  
  # Deploy
  deploy_nixos
  
  # Post-install
  post_install
}

main "$@"
