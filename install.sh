#!/bin/bash
# Cafaye OS: One-Line VPS Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
#   OR
#   ./install.sh (from within the repo)

set -e

# Colors
RED='\033[0;31m'
GREEN='\\033[0;32m'
BLUE='\\033[0;34m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

show_logo() {
  clear
  echo -e "\\033[38;5;180m"
  cat <<'EOF'
     ██████╗ █████╗ ███████╗ █████╗ ██╗   ██╗███████╗
    ██╔════╝██╔══██╗██╔════╝██╔══██╗╚██╗ ██╔╝██╔════╝
    ██║     ███████║█████╗  ███████║ ╚████╔╝ █████╗  
    ██║     ██╔══██║██╔══╝  ██╔══██║  ╚██╔╝  ██╔══╝  
    ╚██████╗██║  ██║██║     ██║  ██║   ██║   ███████╗
     ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝
                                                       
         ☕ Cloud Development, Perfected
EOF
  echo -e "${NC}"
}

# Check if running from repo or need to self-clone
self_clone() {
  local script_dir="$(cd "$(dirname "$0")" && pwd)"
  
  # Check if we're in a valid cafaye repo
  if [[ -f "$script_dir/flake.nix" && -d "$script_dir/installer" ]]; then
    echo "$script_dir"
    return 0
  fi
  
  # We need to clone
  echo -e "${BLUE}Downloading Cafaye OS...${NC}"
  
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  git clone --depth 1 https://github.com/kaka-ruto/cafaye
  cd cafaye
  
  echo -e "${GREEN}✓ Downloaded Cafaye to $temp_dir/cafaye${NC}"
  echo "$temp_dir/cafaye"
}

# Install gum/jq if missing
install_deps() {
  echo -e "${BLUE}Checking dependencies...${NC}"
  
  # Check curl (required for curl-based install)
  if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required${NC}"
    echo "Install curl and try again."
    exit 1
  fi
  
  # Check git (required for clone)
  if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is required${NC}"
    echo "Install git and try again."
    exit 1
  fi
  
  # Try to install gum/jq if missing
  if ! command -v gum &> /dev/null || ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Installing gum and jq...${NC}"
    
    if command -v brew &> /dev/null; then
      brew install gum jq 2>/dev/null || true
    elif command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y jq 2>/dev/null || true
      if ! command -v gum &> /dev/null; then
        nix shell nixpkgs#gum --command true 2>/dev/null || echo -e "${YELLOW}Note: gum not found. Some UI features may be limited.${NC}"
      fi
    elif command -v nix &> /dev/null; then
      nix shell nixpkgs#gum nixpkgs#jq --command true 2>/dev/null || true
    fi
    
    if ! command -v gum &> /dev/null || ! command -v jq &> /dev/null; then
      nix shell nixpkgs#gum nixpkgs#jq --command true 2>/dev/null || echo -e "${YELLOW}Could not install gum/jq automatically. Interactive UI may be limited.${NC}"
    fi
  fi
  
  echo -e "${GREEN}✓ Dependencies ready${NC}"
}

# Auto SSH and run caf-setup after installation
post_install() {
  local target_ip="$1"
  local target_user="$2"
  local ssh_port="${3:-22}"
  
  echo ""
  echo -e "${BLUE}Connecting to your new server...${NC}"
  echo "This may take a minute..."
  echo ""
  
  # Wait for server to reboot
  echo "Waiting for server to reboot (60 seconds)..."
  sleep 60
  
  # SSH and run caf-setup
  echo "Running first-run setup on $target_user@$target_ip..."
  echo ""
  
  # SSH with timeout and retry
  local retries=3
  local connected=false
  
  for i in $(seq 1 $retries); do
    echo "Attempt $i of $retries..."
    
    if ssh -o BatchMode=yes \
           -o ConnectTimeout=30 \
           -o StrictHostKeyChecking=accept-new \
           -p "$ssh_port" \
           "$target_user@$target_ip" \
           "echo 'SSH connected successfully' && caf-setup" 2>/dev/null; then
      connected=true
      break
    else
      echo "Connection failed, retrying in 30 seconds..."
      sleep 30
    fi
  done
  
  if [[ "$connected" == "false" ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Could not automatically connect to your server.${NC}"
    echo ""
    echo "Please connect manually:"
    echo "  ssh $target_user@$target_ip"
    echo "  caf-setup"
    echo ""
  fi
}

# Source helpers and run installation
run_installer() {
  local cafaye_dir="$1"
  
  cd "$cafaye_dir"
  
  # Source helpers
  export CAFAYE_INSTALL_DIR="$cafaye_dir"
  source "$cafaye_dir/installer/all.sh"
  
  show_logo
  
  echo -e "${BLUE}Welcome to the Cafaye OS Installer!${NC}"
  echo -e "${YELLOW}Transform any VPS into your cloud development powerhouse.${NC}"
  echo ""
  
  # Install dependencies
  install_deps
  
  # Gather details
  gather_vps_details
  validate_connectivity
  setup_ssh_keys
  setup_tailscale
  generate_user_state
  show_summary
  
  gum confirm --affirmative="Install Now" --negative="Cancel" "Proceed with installation?" || exit 0
  
  run_installation
  
  echo ""
  gum style --border double --margin "1 2" --padding "2 4" --foreground 212 "✅ Installation Complete!"
  echo ""
  echo "Your server is rebooting..."
  echo ""
  
  # Auto-connect and run caf-setup
  post_install "$TARGET_IP" "$TARGET_USER" "$SSH_PORT"
  
  echo ""
  echo -e "${GREEN}✓ Your Cafaye OS is ready!${NC}"
  echo ""
  echo "If not automatically connected, manually:"
  echo "  ssh $TARGET_USER@$TARGET_IP"
  echo "  caf-setup"
  echo ""
  echo -e "${YELLOW}⚠️  Remember to disable bootstrap_mode for security!${NC}"
}

main() {
  local cafaye_dir
  
  # Self-clone if needed
  cafaye_dir=$(self_clone)
  
  # If we cloned, re-execute this script from the cloned repo
  if [[ "$cafaye_dir" != "$(cd "$(dirname "$0")" && pwd)" ]]; then
    exec "$cafaye_dir/install.sh" "$@"
  fi
  
  # Run installer from repo
  run_installer "$cafaye_dir"
}

main "$@"
