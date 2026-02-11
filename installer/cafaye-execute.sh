#!/usr/bin/env bash
# Cafaye OS: Local NixOS Installation Script
# Handles building and kexecing into a CUSTOM Git-controlled installer

set -e

REPO_DIR="/root/cafaye"
STATE_FILE="/tmp/cafaye-initial-state.json"
LOG_FILE="/var/log/cafaye-install.log"
KEXEC_DIR="$REPO_DIR/installer/kexec"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Cafaye OS Installation Script Started at $(date) ---"

main() {
    echo "=== Starting Cafaye OS Installation ==="
    echo "Model: Custom Kexec Builder"
    echo "Date: $(date)"
    echo ""
    
    # 0. Ensure Swap (Critical for small VPS builds)
    # If memory is less than 3GB, add 2GB swap
    if [[ $(free -m | awk '/^Mem:/{print $2}') -lt 3000 ]]; then
        echo "Checking swap space..."
        if swapon -s | grep -q "/swapfile"; then
             echo "Swap already active."
        else
             echo "Allocating 2GB temporary swap for build process..."
             fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
             chmod 600 /swapfile
             mkswap /swapfile
             swapon /swapfile
             echo "✅ Added 2GB swap."
        fi
    fi

    # 1. Setup Nix
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    if ! command -v nix &> /dev/null; then
        echo "Installing Nix package manager..."
        curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    # 2. Enable flakes
    mkdir -p /etc/nix
    if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
        systemctl restart nix-daemon 2>/dev/null || true
    fi
    
    # 3. Configure Custom Installer
    echo "Configuring custom installer..."
    if [[ -f "$STATE_FILE" ]]; then
        cp "$STATE_FILE" "$KEXEC_DIR/user-state.json"
        echo "✅ User state injected into installer build context."
    else
        echo "⚠️ No state file found at $STATE_FILE. Using defaults."
        touch "$KEXEC_DIR/user-state.json"
    fi
    
    # 4. Build Custom Kexec Bundle
    echo "Building custom Kexec installer (this may take a few minutes)..."
    echo "The installer will include your configuration and runs automatically on boot."
    
    cd "$KEXEC_DIR"
    
    # We must commit files for flakes to see them (unless using --impure, but git is cleaner)
    # Check if we are in a git repo (REPO_DIR is git cloned)
    git config user.email "bootstrap@cafaye.os"
    git config user.name "Cafaye Bootstrap"
    git add .
    git commit -m "Bootstrap state for installer" || true
    
    # Build
    echo "Running nix build..."
    nix build .#default --show-trace
    
    if [[ ! -f result ]]; then
      echo "❌ Build failed!"
      exit 1
    fi
    
    echo "✅ Build complete!"
    echo "Size: $(du -sh result | cut -f1)"
    
    echo ""
    echo "==========================================="
    echo "Ready to kexec into Cafaye Installer!"
    echo "This process is DESTRUCTIVE to the running OS."
    echo "The system will reboot into the installer."
    echo ""
    echo "To reconnect after install (takes ~15 minutes):"
    echo "  ssh root@<vps-ip>" 
    echo "==========================================="
    echo ""
    
    sleep 5
    
    echo "🚀 Launching Kexec Bundle..."
    # The result is a self-extracting script that performs the kexec
    ./result
}

main "$@"
