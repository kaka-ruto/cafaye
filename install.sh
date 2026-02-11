#!/usr/bin/env bash
# Cafaye OS: The "Self-Driving" Bootstrap
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh)

set -e

# --- Configuration ---
REPO_URL="https://github.com/kaka-ruto/cafaye"
REPO_DIR="/root/cafaye"
LOG_FILE="/var/log/cafaye-install.log"

# --- Basics ---
exec > >(tee -a "$LOG_FILE") 2>&1

cat << "EOF"
  ☕ Cafaye OS: The "Self-Driving" Bootstrap
  -----------------------------------------
EOF

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Detect if we are in a pipe - support non-interactive mode with --yes flag
NON_INTERACTIVE=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
    NON_INTERACTIVE=true
    echo "⚡ Running in non-interactive mode with default configuration"
fi

if [[ ! -t 0 ]] && [[ "$NON_INTERACTIVE" != "true" ]]; then
    echo "⚠️  DETECTION: You are running this script via a pipe (curl | bash)."
    echo "   The setup wizard requires an interactive terminal."
    echo ""
    echo "   Options:"
    echo "   1. Run interactively:"
    echo "      bash <(curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh)"
    echo ""
    echo "   2. Run non-interactively with defaults:"
    echo "      curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash -s -- --yes"
    echo ""
    exit 1
fi

echo "Welcome! I've detected a fresh $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2) VPS."
echo "Before we start, I need to:"
echo " 1. Install bootstrap tools: git, jq, gum (TUI engine)"
echo " 2. Clone the Cafaye repository"
echo ""
if [[ "$NON_INTERACTIVE" != "true" ]]; then
    read -p "Ready to prepare the system? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. No changes were made."
        exit 0
    fi
fi

# 1. Install dependencies for the Wizard
echo "Installing bootstrap dependencies (git, jq, gum)..."

# Helper to run commands via Nix if missing
run_cmd() {
    local cmd=$1
    shift
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
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
    VERSION="0.17.0"
    ARCH=$(uname -m)
    [[ "$ARCH" == "x86_64" ]] && GUM_ARCH="x86_64" || GUM_ARCH="arm64"
    URL="https://github.com/charmbracelet/gum/releases/download/v${VERSION}/gum_${VERSION}_Linux_${GUM_ARCH}.tar.gz"
    
    curl -fL "$URL" -o gum.tar.gz
    mkdir -p gum_temp
    tar xzf gum.tar.gz -C gum_temp
    GUM_BIN=$(find gum_temp -name gum -type f | head -n1)
    
    if [[ -n "$GUM_BIN" ]]; then
        chmod +x "$GUM_BIN"
        cp "$GUM_BIN" /usr/local/bin/gum 2>/dev/null || cp "$GUM_BIN" /usr/bin/gum 2>/dev/null || cp "$GUM_BIN" /tmp/gum
        export PATH="/tmp:/usr/local/bin:$PATH"
    fi
    rm -rf gum.tar.gz gum_temp
fi

# 2. Clone the repository
if [[ -d "$REPO_DIR" ]]; then
    echo "Existing Cafaye directory found at $REPO_DIR"
    cd "$REPO_DIR"
    if [[ -d .git ]]; then
        echo "Updating existing Cafaye repository..."
        git config --global --add safe.directory "$REPO_DIR" || true
        run_cmd git pull origin master
    else
        echo "Note: $REPO_DIR is not a git repository. Skipping update."
    fi
else
    echo "Cloning Cafaye repository..."
    run_cmd git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
chmod +x installer/*.sh

# 3. Running the Wizard
if [[ "$NON_INTERACTIVE" == "true" ]]; then
    echo "⚡ Generating default configuration (non-interactive)..."
    STATE_FILE="/tmp/cafaye-initial-state.json"
    cp user/user-state.json.example "$STATE_FILE"
    
    # Auto-detect disk
    disk=$(lsblk -dn -o NAME,TYPE | grep "disk" | head -n1 | awk '{print "/dev/"$1}')
    echo "   Target Disk: $disk"
    jq ".core.boot.grub_device = \"$disk\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    # Auto-import keys
    if [[ -f /root/.ssh/authorized_keys ]]; then
        echo "   Importing SSH keys..."
        keys_json=$(cat /root/.ssh/authorized_keys | jq -R . | jq -s .)
        jq ".core.authorized_keys = $keys_json" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
    
    # Enable bootstrap mode to allow SSH after first boot
    jq '.core.security.bootstrap_mode = true' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    echo "✅ Configuration generated."
else
    # Ensure gum from /tmp is found if it was installed there
    PATH="$PATH" bash ./installer/cafaye-wizard.sh || exit 1
fi

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
    if systemctl is-active --quiet sshd; then
        systemctl restart sshd
    elif systemctl is-active --quiet ssh; then
        systemctl restart ssh
    fi
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
nohup bash ./installer/cafaye-execute.sh > "$LOG_FILE" 2>&1 &

echo "Bootstrap complete. See you on the other side!"
sleep 2
