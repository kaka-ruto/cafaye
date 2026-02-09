#!/bin/bash
# Cafaye OS: Background Execution Script
# This script is designed to be detached from the SSH session.

set -e

REPO_DIR="/root/cafaye"
STATE_FILE="/tmp/cafaye-initial-state.json"
LOG_FILE="/var/log/cafaye-install.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Cafaye OS Background Installation Started at $(date) ---"

# 1. Ensure project is ready
cd "$REPO_DIR"
if [[ -f "$STATE_FILE" ]]; then
    echo "Applying user-selected state..."
    mkdir -p user
    cp "$STATE_FILE" user/user-state.json
fi

# 2. Setup Nix if missing
if ! command -v nix &> /dev/null; then
    echo "Installing Nix..."
    curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. Enable Experimental Features
mkdir -p /etc/nix
if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
    systemctl restart nix-daemon 2>/dev/null || true
fi

# 4. Run NixOS Anywhere (The kexec transition)
echo "Installing nixos-anywhere..."
nix profile install github:nix-community/nixos-anywhere --extra-experimental-features "nix-command flakes"

echo "Executing nixos-anywhere (REBOOT IMMINENT)..."
# We use root@localhost because nixos-anywhere needs an SSH target.
# Since we are already root, we assume setup_ssh_for_localhost was called by bootstrap.
/root/.nix-profile/bin/nixos-anywhere --flake ".#cafaye" root@localhost

echo "--- Installation Finished Successfully at $(date) ---"
