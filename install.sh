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

# Helper to run commands via Nix if missing
run_cmd() {
    local cmd=$1
    shift
    if command -v "$cmd" &> /dev/null; then
        "$cmd" "$@"
    elif command -v nix &> /dev/null; then
        nix --extra-experimental-features "nix-command flakes" run "nixpkgs#$cmd" -- "$@"
    else
        echo "Error: $cmd not found and nix not available."
        exit 1
    fi
}

if command -v apt-get &> /dev/null; then
    apt-get update -y && apt-get install -y git jq curl
elif command -v yum &> /dev/null; then
    yum install -y git jq curl
fi

# Install gum (TUI engine) if not present
if ! command -v gum &> /dev/null; then
    echo "Setting up TUI engine..."
    # Robust gum install for Linux x86_64
    VERSION="0.17.0"
    ARCH=$(uname -m)
    [[ "$ARCH" == "x86_64" ]] && GUM_ARCH="x86_64" || GUM_ARCH="arm64"
    
    URL="https://github.com/charmbracelet/gum/releases/download/v${VERSION}/gum_${VERSION}_Linux_${GUM_ARCH}.tar.gz"
    
    curl -fL "$URL" -o gum.tar.gz
    mkdir -p gum_temp
    tar xzf gum.tar.gz -C gum_temp
    
    # Find the binary wherever it was extracted
    GUM_BIN=$(find gum_temp -name gum -type f | head -n1)
    
    if [[ -n "$GUM_BIN" ]]; then
        chmod +x "$GUM_BIN"
        # Try a few common paths
        cp "$GUM_BIN" /usr/local/bin/gum 2>/dev/null || cp "$GUM_BIN" /usr/bin/gum 2>/dev/null || cp "$GUM_BIN" /bin/gum 2>/dev/null || cp "$GUM_BIN" /tmp/gum
        [[ -f /tmp/gum ]] && export PATH="/tmp:$PATH"
    else
        echo "Error: Could not find gum binary in package."
        exit 1
    fi
    rm -rf gum.tar.gz gum_temp
fi

# 2. Clone the repository
if [[ -d "$REPO_DIR" ]]; then
    echo "Updating existing Cafaye repository..."
    cd "$REPO_DIR" && run_cmd git pull origin master
else
    echo "Cloning Cafaye repository..."
    run_cmd git clone "$REPO_URL" "$REPO_DIR"
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
echo "-----------------------------------------------------------------------"
echo "🚀 DETACHING FROM SESSION"
echo "Cafaye OS is now installing in the background."
echo "You can safely disconnect (Ctrl-C or close window)."
echo ""
echo "ACTION REQUIRED (on your local machine) in ~5 minutes:"
echo "1. Clear old host keys:  ssh-keygen -R $(hostname -I | awk '{print $1}')"
echo "2. Connect to Cafaye:   ssh root@$(hostname -I | awk '{print $1}')"
echo "-----------------------------------------------------------------------"

# Use nohup to detach. The execution script handles the rest.
nohup ./installer/cafaye-execute.sh > "$LOG_FILE" 2>&1 &

echo "Bootstrap complete. See you on the other side!"
sleep 2
