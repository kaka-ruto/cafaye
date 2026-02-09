#!/bin/bash
# Cafaye OS: VPS Installer - Interactive Menu Module

set -e

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[i]${NC} $*"; }

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

# Handle menu choice
handle_menu() {
  local choice=$1

  case "$choice" in
    1)
      echo ""
      log_info "Selected: Install NixOS (full system)"
      echo ""
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
