#!/bin/bash
# Cafaye OS: The "Self-Driving" Bootstrap
# Usage: curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash

set -e

# --- Configuration ---
REPO_URL="https://github.com/kaka-ruto/cafaye"
REPO_DIR="/root/cafaye"
LOG_FILE="/var/log/cafaye-install.log"

# --- Basics ---
echo "☕ Cafaye OS: Starting bootstrap..."

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# 1. Install dependencies for the Wizard
echo "Installing bootstrap dependencies (git, jq, gum)..."
if command -v apt-get &> /dev/null; then
    apt-get update -y && apt-get install -y git jq curl
elif command -v yum &> /dev/null; then
    yum install -y git jq curl
fi

# Install gum (TUI engine) if not present
if ! command -v gum &> /dev/null; then
    echo "Setting up TUI engine..."
    # Simplified gum install for bootstrap
    VERSION="0.14.3"
    curl -fL "https://github.com/charmbracelet/gum/releases/download/v${VERSION}/gum_${VERSION}_linux_amd64.tar.gz" | tar xz --wildcards "**/gum"
    mv gum*/gum /usr/local/bin/
    rm -rf gum*
fi

# 2. Clone the repository
if [[ -d "$REPO_DIR" ]]; then
    echo "Updating existing Cafaye repository..."
    cd "$REPO_DIR" && git pull origin master
else
    echo "Cloning Cafaye repository..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
chmod +x installer/*.sh

# 3. Running the Wizard (Interactively)
./installer/cafaye-wizard.sh || exit 1

# 4. Prepare for Detached Execution
echo "Setting up localhost SSH for automated installation..."
mkdir -p /root/.ssh
if [[ ! -f /root/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -C "cafaye-bootstrap"
fi
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Enable root login temporarily for localhost
if [[ -f /etc/ssh/sshd_config ]]; then
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl restart sshd || systemctl restart ssh || true
fi

# 5. Launch Background Execution
echo ""
echo "-----------------------------------------------------------------------"
echo "🚀 DETACHING FROM SESSION"
echo "Cafaye OS is now installing in the background."
echo "You can safely disconnect (Ctrl-C or close window)."
echo "Log file: $LOG_FILE"
echo "Machine will reboot into Cafaye OS in approximately 3-5 minutes."
echo "-----------------------------------------------------------------------"

# Use nohup to detach. The execution script handles the rest.
nohup ./installer/cafaye-execute.sh > "$LOG_FILE" 2>&1 &

echo "Bootstrap complete. See you on the other side!"
sleep 2
