#!/bin/bash
# scripts/vps_deploy.sh
# Syncs current codebase to VPS and runs installer

VPS_IP="34.10.103.233"
SSH_USER="kaka"
SSH_KEY="$HOME/.ssh/cafaye"

echo "☕ Preparing to deploy Cafaye to VPS: $VPS_IP"

# 1. Sync files
echo "📦 Syncing files..."
rsync -avz \
  --exclude '.git' \
  --exclude '.devbox' \
  --exclude 'result' \
  --exclude 'local-user.nix' \
  --exclude 'environment.json' \
  --exclude 'settings.json' \
  -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
  ./ $SSH_USER@$VPS_IP:~/cafaye-src

# 2. Run installer in non-interactive mode
echo "🚀 Running installer..."
ssh -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_USER@$VPS_IP "cd ~/cafaye-src && bash install.sh --yes"

echo "✅ Deployment and installation triggered."
