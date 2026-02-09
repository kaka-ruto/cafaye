# VPS Installation Guide for Cafaye OS

This guide covers installing Cafaye OS on a VPS (Virtual Private Server) using the NixOS installer.

## Prerequisites

- A VPS with at least 2GB RAM and 20GB disk space
- SSH access to the VPS as root
- The VPS should be running a Linux distribution (Ubuntu, Debian, etc.)

## Quick Start

### Option 1: Automated Installation (Recommended)

Run the installer directly on your VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -s -- --yes
```

This will:
1. Install Nix (if not present)
2. Download the NixOS installer
3. Reboot into the NixOS installer
4. Automatically complete the installation

### Option 2: Manual Installation

If the automated installer fails or you need more control:

1. **Boot into NixOS installer:**
   ```bash
   # From the automated installer, or manually:
   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
   # Select option 1 to install NixOS
   ```

2. **Once in the NixOS installer environment:**
   ```bash
   # The installer will have set up SSH keys and started the installation
   # If you need to manually complete it:
   
   # Mount the disks
   mkdir -p /mnt
   mount /dev/sda1 /mnt
   mkdir -p /mnt/boot
   mount /dev/sda15 /mnt/boot
   
   # Clone cafaye configuration
   mkdir -p /mnt/root
   cd /mnt/root
   curl -fsSL https://github.com/kaka-ruto/cafaye/archive/refs/heads/master.tar.gz | tar xz
   mv cafaye-master cafaye
   
   # Install NixOS channel
   nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
   nix-channel --update
   
   # Create minimal configuration
   cat > /mnt/etc/nixos/configuration.nix << 'EOF'
   { config, pkgs, ... }:
   {
     imports = [ ./hardware-configuration.nix ];
     
     boot.loader.grub = {
       enable = true;
       device = "/dev/sda";
     };
     
     networking.hostName = "cafaye";
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     
     services.openssh = {
       enable = true;
       settings = {
         PermitRootLogin = "yes";
         PasswordAuthentication = true;
       };
     };
     
     users.users.root.initialPassword = "changeme";
     
     environment.systemPackages = with pkgs; [ git curl vim ];
     system.stateVersion = "24.05";
   }
   EOF
   
   # Generate hardware config
   nixos-generate-config --root /mnt
   
   # Install NixOS
   nixos-install --root /mnt --no-root-passwd
   
   # Reboot
   reboot
   ```

3. **After reboot, apply full Cafaye configuration:**
   ```bash
   # SSH into the new NixOS system
   ssh root@<vps-ip>
   
   # Clone cafaye if not present
   git clone https://github.com/kaka-ruto/cafaye.git /root/cafaye
   cd /root/cafaye
   
   # Copy your user-state.json or use the minimal one
   # Edit user/user-state.json to enable desired features
   
   # Apply configuration
   nixos-rebuild switch --flake .#cafaye
   ```

## Troubleshooting

### Issue: "No space left on device" during installation

**Cause:** The NixOS installer runs in a tmpfs with limited space.

**Solution:**
```bash
# Add zram for swap
modprobe zram
echo 4G > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon /dev/zram0

# Clean nix store
nix store gc
```

### Issue: "file 'nixpkgs/nixos' was not found"

**Cause:** NIX_PATH is not set correctly.

**Solution:**
```bash
nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
nix-channel --update
```

### Issue: "attribute 'userState' missing"

**Cause:** The cafaye modules require userState but it's not being passed.

**Solution:** Use the minimal configuration first, then apply full cafaye after reboot.

### Issue: Conflicting definitions

**Cause:** Multiple modules defining the same options.

**Solution:** We fixed this in the hardware/vps.nix - ensure you're using the latest version.

## Post-Installation

1. **Change the root password:**
   ```bash
   passwd
   ```

2. **Set up SSH keys:**
   ```bash
   mkdir -p ~/.ssh
   echo "your-ssh-key" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Enable Tailscale (optional):**
   ```bash
   # Edit user/user-state.json
   # Set core.tailscale_enabled to true
   # Add your auth key to secrets/tailscale-auth-key.txt
   caf system rebuild
   ```

4. **Configure your tools:**
   ```bash
   # Edit user/user-state.json to enable desired features
   vim user/user-state.json
   
   # Apply changes
   caf system rebuild
   ```

## Architecture

The installation process works as follows:

1. **Phase 1 - Preparation:**
   - Run on existing Linux system
   - Install Nix package manager
   - Download NixOS installer kernel
   - Configure kexec

2. **Phase 2 - NixOS Installer:**
   - Reboot into NixOS installer (in-memory)
   - Mount target disk
   - Generate hardware configuration
   - Install minimal NixOS system

3. **Phase 3 - Full System:**
   - Reboot into installed NixOS
   - Clone cafaye repository
   - Apply full configuration with flakes

## Files Modified

During the installation troubleshooting, we made these improvements:

1. **install.sh** - Fixed NixOS installer detection (case-insensitive)
2. **hardware/vps.nix** - Added disko configuration for disk partitioning
3. **core/hardware.nix** - Removed conflicting filesystem definitions
4. **flake.nix** - Added disko input for disk partitioning

## Known Limitations

- Minimum 2GB RAM recommended (1GB with zram might work)
- 20GB disk space minimum
- Some VPS providers may require specific kernel modules
- DigitalOcean requires additional network configuration (handled automatically)

## Getting Help

If you encounter issues:

1. Check the logs: `journalctl -xe`
2. Run the doctor: `caf system doctor`
3. Check factory status: `caf factory check`
4. Collect debug info: `caf debug collect`

## Security Notes

- The initial installation enables password authentication for root
- **IMPORTANT:** Change the root password immediately after first login
- Set up SSH keys and disable password authentication
- Enable Tailscale for zero-trust access
- Review the security settings in `core/security.nix`
