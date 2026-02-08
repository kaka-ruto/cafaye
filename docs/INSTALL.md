# Installing Cafaye OS

Cafaye OS is designed to be installed on a fresh VPS (Virtual Private Server) or bare metal server. We use `nixos-anywhere` to perform the installation over SSH.

## Prerequisites

1. **A Target Machine**: A VPS (e.g., DigitalOcean, Hetzner, AWS, Vultr) or physical server accessible via SSH.
   - Requires root access
   - Recommended: 2+ vCPUs, 4GB+ RAM
   - Must have a supported disk device (see Disk Configuration below)
2. **Nix Installed Locally**: Your local machine must have Nix installed
3. **SSH Key Access**: You need SSH key authentication to the target VPS
4. **Tailscale Auth Key** (Optional but Recommended): For secure access post-installation

## Disk Configuration

Cafaye uses `nixos-anywhere` which automatically partitions and formats the target disk. The disk is:
- **Wiped completely** during installation
- Formatted with a single ext4 partition labeled `nixos`
- GRUB bootloader installed to the device specified in your configuration

### Supported Disk Devices

The installer defaults to `/dev/vda` (common for KVM VPS providers). If your VPS uses a different device, update `user/user-state.json` before running the installer:

```json
{
  "core": {
    "boot": {
      "grub_device": "/dev/sda"
    }
  }
}
```

Common device names:
- `/dev/vda` - KVM/QEMU virtual machines (DigitalOcean, Hetzner Cloud)
- `/dev/sda` - Xen, VMware, or older KVM instances
- `/dev/nvme0n1` - NVMe SSDs on bare metal or modern VPS

**To check your disk device before installing:**
```bash
ssh root@<your-vps-ip> lsblk
```

## Installation Steps

### 1. Prepare Your Configuration

Before running the installer, customize your `user/user-state.json`:

```bash
# Copy the example configuration
cp user/user-state.json.example user/user-state.json

# Edit to add your SSH public key and choose your stack
nano user/user-state.json
```

Key settings to update:
- `core.authorized_keys`: Add your SSH public key(s)
- `core.boot.grub_device`: Set to match your VPS disk (see above)
- `core.security.bootstrap_mode`: Set to `true` for initial setup (see Bootstrap Mode)
- `languages`, `services`, `frameworks`: Enable what you need

### 2. Run the Installer

From the root of the Cafaye repository:
```bash
./install.sh
```

### 3. Follow the Prompts

- **Target IP**: The IP address of your VPS
- **SSH User**: Usually `root`, but depends on your provider
- **SSH Port**: Default is 22
- **Tailscale Key**: Paste a reusable auth key (starts with `tskey-auth-...`)

### 4. Wait for Completion

The installer will:
- Build the system configuration locally
- Push the closure to the target
- Install NixOS to the target disk (**wiping all existing data**)
- Reboot the machine

This typically takes 5-10 minutes depending on your connection and VPS performance.

## Bootstrap Mode (Important!)

For initial setup, we recommend enabling **bootstrap mode** in your `user-state.json`:

```json
{
  "core": {
    "security": {
      "bootstrap_mode": true
    }
  }
}
```

**What bootstrap mode does:**
- Opens SSH on all network interfaces (not just Tailscale)
- Disables fail2ban temporarily
- Allows you to connect directly if Tailscale has issues

**After confirming Tailscale works:**
1. SSH into your server
2. Run `caf-setup` to complete configuration
3. Edit `user-state.json` and set `bootstrap_mode: false`
4. Run `caf-system-rebuild` to apply secure settings

**⚠️  Security Warning**: Always disable bootstrap mode after initial setup!

## Post-Installation

Once the machine reboots:

### 1. Connect

If using bootstrap mode:
```bash
ssh root@<TARGET_IP>
```

If Tailscale is configured:
```bash
ssh root@<TARGET_IP>  # Or via Tailscale: ssh root@cafaye
```

### 2. First Run Setup

Log in and run the setup wizard:
```bash
caf-setup
```

This interactive wizard will help you:
- Verify your configuration
- Set up your preferred editor and distribution
- Configure languages and frameworks
- Run initial system updates

### 3. Disable Bootstrap Mode

After confirming everything works:
```bash
# Edit the state file
sudo nano /etc/cafaye/user-state.json
# Set bootstrap_mode to false, then rebuild
sudo caf-system-rebuild
```

## Troubleshooting

### "Permission denied (publickey)"
Ensure you have an SSH key added to your local agent that is authorized on the target VPS. Add your key to `user/user-state.json` before installing.

### "Nix not found"
The installer script requires Nix on your local machine. Install it first:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### "Device not found" or GRUB installation fails
Your VPS may use a different disk device. Check with `lsblk` on the target and update `core.boot.grub_device` in your configuration.

### Locked out after installation
If you can't connect after the reboot:
1. Use your VPS provider's console/VNC access
2. Log in as root (password is shown during install)
3. Check Tailscale status: `tailscale status`
4. Verify SSH is running: `systemctl status sshd`
5. If needed, manually enable bootstrap mode by editing `/etc/cafaye/user-state.json`

### Tailscale not connecting
- Verify your auth key is valid and not expired
- Check that the key is in `secrets/secrets.yaml` (encrypted with sops)
- Try running `sudo tailscale up` manually to see errors

## Advanced: Manual Installation

If the automated installer doesn't work for your use case, you can use `nixos-anywhere` directly:

```bash
# Install nixos-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake .#cafaye \
  --ssh-port 22 \
  root@<your-vps-ip>
```

For disks other than `/dev/vda`, you'll need to create a custom disk configuration module.

## Provider-Specific Notes

### DigitalOcean
- Default disk: `/dev/vda`
- Requires SSH key in DO control panel for initial access

### Hetzner Cloud
- Default disk: `/dev/sda`
- Update `grub_device` before installing

### AWS EC2
- Disk varies by instance type: `/dev/xvda` or `/dev/nvme0n1`
- Check with `lsblk` first

### Vultr
- Default disk: `/dev/vda`
- Works out of the box

## Getting Help

- Run `caf-system-doctor` on the VPS for health checks
- Run `caf-debug-collect` to gather system information
- Check the [Cafaye documentation](../README.md) for more details
- Review the [CHANGELOG](../CHANGELOG.md) for recent changes
