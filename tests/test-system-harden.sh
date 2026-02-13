#!/bin/bash
set -euo pipefail

# Cafaye OS System Hardening Test
# Provisions a VPS and verifies automatic system hardening

# ... (Standard headers similar to test-fresh-install.sh) ...
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

VPS_NAME="caf-test-harden-$(date +%s)"
ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"
CLEANUP=true

log() { echo -e "${BLUE}[TEST]${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }

cleanup() {
    if [[ "$CLEANUP" == "true" ]]; then
        log "Cleaning up VPS..."
        gcloud compute instances delete "$VPS_NAME" --zone="$ZONE" --quiet >/dev/null 2>&1 || true
        success "VPS deleted"
    fi
}
trap cleanup EXIT

log "Creating test VPS: $VPS_NAME"
SSH_USER=$(whoami)
SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
[[ ! -f "$SSH_PUB_KEY" ]] && SSH_PUB_KEY="$HOME/.ssh/id_rsa.pub"

if [[ ! -f "$SSH_PUB_KEY" ]]; then
    error "No SSH public key found"
    exit 1
fi

gcloud compute instances create "$VPS_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-2404-lts-amd64 \
    --metadata=ssh-keys="${SSH_USER}:$(cat "$SSH_PUB_KEY")" \
    --quiet >/dev/null

VPS_IP=$(gcloud compute instances describe "$VPS_NAME" --zone="$ZONE" --format='get(networkInterfaces[0].accessConfigs[0].externalIp)')
log "VPS created: $VPS_IP"

# Wait for SSH
log "Waiting for SSH..."
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"
for i in {1..60}; do
    if ssh $SSH_OPTS "${SSH_USER}@${VPS_IP}" "echo ok" &>/dev/null; then
        success "SSH ready"
        break
    fi
    sleep 2
done

# Prepare execution command
SSH_CMD="ssh $SSH_OPTS ${SSH_USER}@${VPS_IP}"

# 1. Clone Repo
log "Cloning repository..."
$SSH_CMD "git clone --depth 1 https://github.com/cafaye/cafaye.git /tmp/cafaye-test"

# 2. Pre-seed settings.json to enable VPS mode
log "Pre-seeding VPS settings..."
$SSH_CMD "mkdir -p ~/.config/cafaye"
$SSH_CMD "echo '{\"core\": {\"vps\": true}}' > ~/.config/cafaye/settings.json"

# 3. Run Installer (should trigger hardening)
log "Running installer..."
$SSH_CMD "cd /tmp/cafaye-test && ./install.sh --yes"

# 4. Verify Hardening
log "Verifying Hardening..."

# Check SSH Config
SSH_CONFIG_CHECK=$($SSH_CMD "sudo grep '^PasswordAuthentication no' /etc/ssh/sshd_config || echo 'fail'")
if [[ "$SSH_CONFIG_CHECK" == "fail" ]]; then
    error "SSH hardening failed (PasswordAuthentication not disabled)"
    exit 1
fi
success "SSH PasswordAuthentication disabled"

# Check UFW
UFW_STATUS=$($SSH_CMD "sudo ufw status | grep 'Status: active' || echo 'fail'")
if [[ "$UFW_STATUS" == "fail" ]]; then
    error "UFW is not active"
    exit 1
fi
success "UFW firewall is active"

log "System Hardening Test Passed! ✨"
exit 0
