#!/bin/bash
# Cafaye OS: VPS Bootstrap Script
# This is a wrapper around nixos-anywhere for easy installation.

# Exit on error
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for gum
if ! command -v gum &> /dev/null; then
    echo -e "${BLUE}Gum is not installed. Cafaye OS installer uses 'gum' for prompts.${NC}"
    echo "You can run this script with 'nix shell nixpkgs#gum --command ./install.sh'"
    echo "Or install it manually."
    exit 1
fi

# Show Logo
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

echo -e "${BLUE}☕ Welcome to the Cafaye OS Installer!${NC}"
echo "------------------------------------------"

# Ensure Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${RED}Error: Nix is required to run the installer.${NC}"
    echo "Please install Nix first: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    exit 1
fi

# Step 1: Target User & IP
echo ""
echo "📝 Target VPS Details"
TARGET_USER=$(gum input --placeholder "root" --value "root" --header "SSH User")
TARGET_IP=$(gum input --placeholder "1.2.3.4" --header "Target IP Address")

if [ -z "$TARGET_IP" ]; then
    echo "No IP provided. Exiting."
    exit 1
fi

# Step 2: SSH Port
SSH_PORT=$(gum input --placeholder "22" --value "22" --header "SSH Port")

# Step 3: Tailscale Auth Key (Optional)
echo ""
echo "🔒 Tailscale Setup (Highly Recommended)"
TS_AUTH_KEY=$(gum input --password --placeholder "tskey-auth-..." --header "Tailscale Auth Key (optional)")

# Build extra files if TS key is provided
EXTRA_FILES=""
TMP_DIR=""
if [ -n "$TS_AUTH_KEY" ]; then
    TMP_DIR=$(mktemp -d)
    # We place the key where our NixOS config expects it, or at a standard location
    # Ideally, sops takes care of this, but for bootstrapping, we can inject it.
    # If the user's config expects sops, this injection might be ignored unless we configure it.
    # For now, let's inject it to /var/lib/tailscale/auth-key and hope the config uses it or user updates it later.
    mkdir -p "$TMP_DIR/var/lib/tailscale"
    echo "$TS_AUTH_KEY" > "$TMP_DIR/var/lib/tailscale/auth-key"
    EXTRA_FILES="--extra-files $TMP_DIR"
    echo "🔑 Tailscale key queued for injection."
fi

# Confirm
echo ""
gum style --border double --margin "1 2" --padding "1 2" --foreground 212 \
"Ready to install on $TARGET_USER@$TARGET_IP:$SSH_PORT"

echo "⚠️  WARNING: This will WIPE the target disk!"
gum confirm "Proceed with installation?" || exit 0

echo ""
echo "🚀 Starting installation via nixos-anywhere..."

# Run nixos-anywhere
# We use --flake .#cafaye to use the local flake configuration
nix run github:nix-community/nixos-anywhere -- \
    --flake .#cafaye \
    --ssh-port "$SSH_PORT" \
    $EXTRA_FILES \
    "$TARGET_USER@$TARGET_IP"

# Cleanup
if [ -n "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

echo ""
caf-logo-show 2>/dev/null || true
gum style --border double --margin "1 2" --padding "2 4" --foreground 212 "Installation Complete! ☕"

echo ""
echo "Next Steps:"
echo "1. Wait for reboot"
echo "2. SSH into your new server: ssh $TARGET_USER@$TARGET_IP"
echo "3. Run 'caf-setup' to configure your environment"
