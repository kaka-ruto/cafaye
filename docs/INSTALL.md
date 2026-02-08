# Installing Cafaye OS

Cafaye OS is designed to be installed on a fresh VPS (Virtual Private Server) or bare metal server. We use `nixos-anywhere` to perform the installation over SSH.

## Prerequisites

1. **A Target Machine**: A VPS (e.g., DigitalOcean, Hetzner, AWS) or physical server accessible via SSH.
   - Requires root access.
   - Recommended: 2+ vCPUs, 4GB+ RAM.
2. **Nix Installed Locally**: Your local machine must have Nix installed.
3. **Tailscale Auth Key** (Optional but Recommended): For secure access post-installation.

## Installation Steps

1. **Run the Installer**:
   From the root of the Cafaye repository:
   ```bash
   ./install.sh
   ```

2. **Follow the Prompts**:
   - **Target IP**: The IP address of your VPS.
   - **SSH User**: Usually `root`, but depends on your provider.
   - **SSH Port**: Default is 22.
   - **Tailscale Key**: Paste a reusable auth key (start with `tskey-auth-...`).

3. **Wait for Completion**:
   The installer will:
   - Build the system configuration locally.
   - Push the closure to the target.
   - Install NixOS to the target disk (wiping existing data).
   - Reboot the machine.

## Post-Installation

Once the machine reboots:

1. **Connect**:
   - Via SSH: `ssh root@<TARGET_IP>`
   - Via Tailscale: `ssh root@cafaye` (if you provided a key and DNS is set up)

2. **First Run Setup**:
   Log in and run:
   ```bash
   caf-setup
   ```
   This wizard will help you configure your editor, languages, and tools.

## Troubleshooting

- **"Permission denied (publickey)"**: Ensure you have an SSH key added to your local agent that is authorized on the target VPS.
- **"Nix not found"**: The installer script will attempt to install Nix if missing, but it's better to verify your local environment first.
