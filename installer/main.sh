#!/bin/bash
# Cafaye OS: Main Installer
# Usage: Run directly from repo or via curl|bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect if running from pipe (curl|bash or source <(...))
is_pipe_mode() {
  [[ -z "${BASH_SOURCE[0]}" ]]
}

show_logo() {
  clear
  echo -e "\033[38;5;180m"
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

# Get directory where scripts are located
get_script_dir() {
  if is_pipe_mode; then
    pwd
  else
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
  fi
}

# Source all helpers
source_helpers() {
  local script_dir="$1"
  export CAFAYE_INSTALL_DIR="$script_dir"
  source "$script_dir/installer/all.sh"
}

# Install gum/jq if missing
install_deps() {
  echo -e "${BLUE}Checking dependencies...${NC}"
  
  if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required${NC}"
    exit 1
  fi
  
  if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is required${NC}"
    exit 1
  fi
  
  if ! command -v gum &> /dev/null || ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Installing gum and jq...${NC}"
    
    if command -v brew &> /dev/null; then
      brew install gum jq 2>/dev/null || true
    elif command -v nix &> /dev/null; then
      nix shell nixpkgs#gum nixpkgs#jq --command true 2>/dev/null || true
    fi
    
    echo -e "${YELLOW}Could not install gum/jq automatically. Interactive UI may be limited.${NC}"
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
  
  echo "Waiting for server to reboot (60 seconds)..."
  sleep 60
  
  echo "Running first-run setup on $target_user@$target_ip..."
  echo ""
  
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
    echo -e "${YELLOW}Could not automatically connect to your server.${NC}"
    echo ""
    echo "Please connect manually:"
    echo "  ssh $target_user@$target_ip"
    echo "  caf-setup"
    echo ""
  fi
}

# Main installation flow
run_installer() {
  show_logo
  
  echo -e "${BLUE}Welcome to the Cafaye OS Installer!${NC}"
  echo -e "${YELLOW}Transform any VPS into your cloud development powerhouse.${NC}"
  echo ""
  
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
  
  post_install "$TARGET_IP" "$TARGET_USER" "$SSH_PORT"
  
  echo ""
  echo -e "${GREEN}✓ Your Cafaye OS is ready!${NC}"
  echo ""
  echo "If not automatically connected, manually:"
  echo "  ssh $TARGET_USER@$TARGET_IP"
  echo "  caf-setup"
  echo ""
  echo -e "${YELLOW}Remember to disable bootstrap_mode for security!${NC}"
}

# Entry point - call with the install directory
main() {
  local install_dir="${1:-$(get_script_dir)}"
  
  # Source helpers from the install directory
  source_helpers "$install_dir"
  
  # Run the installer
  run_installer
}

# Export functions so they can be used after sourcing
export -f get_script_dir
export -f source_helpers
export -f install_deps
export -f post_install
export -f run_installer
export -f show_logo
