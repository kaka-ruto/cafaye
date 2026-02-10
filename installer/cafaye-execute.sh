#!/usr/bin/env bash
# Cafaye OS: Local NixOS Installation Script
# Handles kexec into installer and completes installation

set -e

REPO_DIR="/root/cafaye"
STATE_FILE="/tmp/cafaye-initial-state.json"
LOG_FILE="/var/log/cafaye-install.log"
KEXEC_MARKER="/tmp/cafaye-kexec-done"
INSTALLER_SCRIPT="/tmp/cafaye-installer.sh"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Cafaye OS Installation Script Started at $(date) ---"

# Function to create the installer script that runs after kexec
create_installer_script() {
    cat > "$INSTALLER_SCRIPT" << 'INSTALLEREOF'
#!/bin/bash
set -e

REPO_DIR="/mnt/root/cafaye"
STATE_FILE="/tmp/cafaye-initial-state.json"
LOG_FILE="/var/log/cafaye-install.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Running in NixOS Installer Environment ==="
echo "Date: $(date)"

# Wait for network
echo "Waiting for network connectivity..."
for i in {1..60}; do
    if ping -c 1 github.com &>/dev/null; then
        echo "Network is ready"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "WARNING: Network not available after 2 minutes, continuing anyway..."
    fi
    sleep 2
done

# Clone cafaye repo if not present
if [[ ! -d "$REPO_DIR" ]]; then
    echo "Cloning Cafaye repository..."
    mkdir -p /mnt/root
    cd /mnt/root
    git clone https://github.com/kaka-ruto/cafaye.git || {
        echo "ERROR: Failed to clone repository"
        exit 1
    }
fi

cd "$REPO_DIR"

# Apply user state if provided
if [[ -f "$STATE_FILE" ]]; then
    echo "Applying user-selected state..."
    mkdir -p user
    cp "$STATE_FILE" user/user-state.json
    echo "State file applied successfully"
fi

# Generate hardware configuration
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

# Get disk from state file or use default
DISK=$(jq -r '.core.boot.grub_device // "/dev/sda"' user/user-state.json 2>/dev/null || echo "/dev/sda")
echo "Using disk: $DISK"

# Create minimal configuration.nix
echo "Creating NixOS configuration..."
cat > /mnt/etc/nixos/configuration.nix << NIXEOF
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  
  boot.loader.grub = {
    enable = true;
    device = "${DISK}";
  };
  
  networking.hostName = "cafaye";
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # SSH for initial access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  
  # Set root password
  users.users.root.initialPassword = "cafaye";
  
  # Basic packages
  environment.systemPackages = with pkgs; [ git curl vim ];
  
  system.stateVersion = "24.05";
}
NIXEOF

echo "Installing NixOS (this may take 15-30 minutes)..."
echo "Starting at: $(date)"

# Run nixos-install with error handling
if nixos-install --root /mnt --no-root-passwd; then
    echo "NixOS installation completed successfully at: $(date)"
    
    # Copy cafaye repo to new system
    echo "Copying Cafaye configuration to new system..."
    mkdir -p /mnt/root/cafaye
    cp -r "$REPO_DIR"/* /mnt/root/cafaye/ 2>/dev/null || true
    cp -r "$REPO_DIR"/.git /mnt/root/cafaye/ 2>/dev/null || true
    
    echo "Installation complete! Rebooting in 10 seconds..."
    sleep 10
    reboot
else
    echo "ERROR: NixOS installation failed at: $(date)"
    echo "Check logs at: $LOG_FILE"
    exit 1
fi
INSTALLEREOF

    chmod +x "$INSTALLER_SCRIPT"
}

# Function to check if we're in the NixOS installer environment
is_in_installer() {
    [[ -f /etc/NIXOS ]] && [[ -f /etc/nixos-installer ]]
}

# Function to run in the NixOS installer
run_in_installer() {
    echo "Detected NixOS installer environment"
    
    # Copy the installer script and run it
    if [[ -f "$INSTALLER_SCRIPT" ]]; then
        cp "$INSTALLER_SCRIPT" /tmp/installer.sh
        chmod +x /tmp/installer.sh
        exec /tmp/installer.sh
    else
        echo "ERROR: Installer script not found at $INSTALLER_SCRIPT"
        exit 1
    fi
}

# Main installation logic
main() {
    # Check if we're already in the installer
    if is_in_installer; then
        run_in_installer
        return
    fi
    
    echo "=== Starting Cafaye OS Installation ==="
    echo "Date: $(date)"
    echo ""
    
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
    
    # 3. Create installer script for post-kexec
    echo "Creating installer script..."
    create_installer_script
    
    # 4. Download and prepare kexec
    echo "Downloading NixOS kexec installer..."
    KEXEC_URL="https://github.com/nix-community/nixos-images/releases/download/nixos-25.05/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz"
    
    curl -fL "$KEXEC_URL" -o /tmp/kexec.tar.gz || {
        echo "ERROR: Failed to download kexec installer"
        exit 1
    }
    
    echo "Extracting kexec installer..."
    mkdir -p /tmp/kexec
    tar xzf /tmp/kexec.tar.gz -C /tmp/kexec
    
    # Mark that we've done the kexec setup
    touch "$KEXEC_MARKER"
    
    echo ""
    echo "==========================================="
    echo "Ready to kexec into NixOS installer!"
    echo ""
    echo "The system will now reboot into the NixOS installer."
    echo "The installation will continue automatically."
    echo ""
    echo "This terminal session will be lost."
    echo "To reconnect after reboot (takes ~5 minutes):"
    echo "  ssh root@<vps-ip>"
    echo "  Password: cafaye"
    echo "==========================================="
    echo ""
    
    # Copy installer script to a location that persists after kexec
    cp "$INSTALLER_SCRIPT" /tmp/kexec/
    
    # Give user time to read the message
    sleep 10
    
    # Run kexec - this reboots into the installer
    echo "Executing kexec now..."
    cd /tmp/kexec && ./kexec
}

# Run main
main "$@"
