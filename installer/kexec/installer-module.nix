{ config, pkgs, modulesPath, ... }:

let
  # The installer script that runs automatically on boot
  cafayeInstaller = pkgs.writeShellScript "cafaye-installer.sh" ''
    set -euo pipefail
    
    # Send logs to console and journal
    exec > >(tee -a /dev/console) 2>&1
    
    echo ""
    echo "================================================================="
    echo "   ☕ Cafaye OS: The 'Self-Driving' Installer (Kexec Mode)"
    echo "================================================================="
    echo ""
    
    # 1. Wait for network
    echo "[cafaye] Waiting for network connectivity..."
    for i in {1..60}; do
        if ping -c 1 github.com &>/dev/null; then
            echo "[cafaye] Network is ready!"
            break
        fi
        sleep 2
    done
    
    # 2. Clone the repository
    REPO_DIR="/root/cafaye"
    echo "[cafaye] Cloning repository..."
    rm -rf "$REPO_DIR"
    mkdir -p "$REPO_DIR"
    
    if command -v git &>/dev/null; then
        git clone https://github.com/kaka-ruto/cafaye.git "$REPO_DIR"
    else
        # Fallback to curl if git is somehow missing
        curl -L https://github.com/kaka-ruto/cafaye/archive/refs/heads/master.tar.gz | tar xz -C "$REPO_DIR" --strip-components=1
    fi
    
    cd "$REPO_DIR"
    
    # 3. Restore user state if baked in
    if [[ -f /etc/cafaye/user-state.json ]]; then
        echo "[cafaye] Restoring user configuration..."
        mkdir -p user
        cp /etc/cafaye/user-state.json user/user-state.json
    fi
    
    # 4. Identify target disk
    DISK=$(jq -r '.core.boot.grub_device // "/dev/sda"' user/user-state.json 2>/dev/null || echo "/dev/sda")
    echo "[cafaye] Targeting disk: $DISK"

    # Safety: unmount everything
    umount -R /mnt 2>/dev/null || true
    
    # 5. Execute Installation
    echo "[cafaye] Starting disko partitioning..."
    # Run disko to partition and mount to /mnt
    # We use disko from the input directly or via nix run if needed
    # Since we are inside a minimal environment, let's use nix run to be safe and get latest deps
    if command -v disko-install &>/dev/null; then
        disko-install --flake .#cafaye --disk main "$DISK"
    else
        nix run github:nix-community/disko -- --mode disko --flake .#cafaye --disk main "$DISK"
    fi
    
    echo "[cafaye] Starting NixOS installation..."
    # Generate hardware config if needed? No, flake handles it.
    # Run installation
    nixos-install --flake .#cafaye --root /mnt --no-root-passwd
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✅ Installation SUCCESS!"
        echo "Rebooting into your new Cafaye OS in 10 seconds..."
        sleep 10
        # Check if we are in a test env or real env
        # In tests reboot often just terminates the vm
        reboot
    else
        echo "❌ Installation FAILED!"
        echo "Dropping to shell for debugging."
        echo "Check journalctl -u cafaye-install for full logs."
        exit 1
    fi
  '';

in {
  # System Configuration
  networking.hostName = "cafaye-installer";
  
  # Ensure SSH works for debugging
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  
  # Bake the user state into the image if it exists
  environment.etc."cafaye/user-state.json" = {
    source = ./user-state.json;
  };

  # Define the installer service
  systemd.services.cafaye-install = {
    description = "Cafaye Self-Driving Installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
      StandardError = "journal+console";
      TimeoutStartSec = "30min";
    };
    
    path = with pkgs; [ 
      bash 
      coreutils 
      util-linux 
      curl 
      git 
      jq 
      iproute2 
      openssh
      nix
      nixos-install-tools # Important for nixos-install
    ];
    
    script = "${cafayeInstaller}";
  };
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  environment.systemPackages = [ 
    pkgs.git 
    pkgs.jq 
  ];
}
