#!/bin/bash
# Cafaye OS: VPS Bootstrap Script
# This is a wrapper around nixos-anywhere for easy installation.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
cat config/cafaye/branding/logo.txt
echo -e "${NC}"

echo -e "${BLUE}☕ Welcome to the Cafaye OS Installer!${NC}"
echo "------------------------------------------"

# Check for nix
if ! command -v nix &> /dev/null; then
    echo -e "${RED}Error: nix is not installed.${NC}"
    echo "Please install nix first: curl -L https://nixos.org/nix/install | sh"
    exit 1
fi

# Check for nixos-anywhere
if ! nix shell nixpkgs#nixos-anywhere --command nixos-anywhere --version &> /dev/null; then
  echo -e "${BLUE}Info: nixos-anywhere will be fetched from nixpkgs during installation.${NC}"
fi

usage() {
    echo "Usage: $0 <ip-address> [ssh-port]"
    echo "Example: $0 1.2.3.4 22"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

IP="$1"
PORT="${2:-22}"

echo -e "${GREEN}Ready to install Cafaye OS on ${IP}:${PORT}${NC}"
echo "This will wipe the data on the target VPS. Do you want to continue? (y/N)"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Run nixos-anywhere
# Note: We assume the user has set up their SSH keys to the target VPS
# and has a local key for sops/age decryption if required.
nix run github:nix-community/nixos-anywhere -- \
    --flake .#cafaye-vps \
    --ssh-port "$PORT" \
    "$IP"

echo -e "${GREEN}✓ Cafaye OS installation attempted on ${IP}${NC}"
echo "Once the machine reboots, connect via Tailscale SSH."
