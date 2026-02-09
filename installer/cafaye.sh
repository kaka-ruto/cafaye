#!/bin/bash
# Cafaye OS: VPS Installer - Cafaye Repository Module

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[i]${NC} $*"; }
log_ok() { echo -e "${GREEN}[✓]${NC} $*"; }

# Clone or update Cafaye
clone_or_update_cafaye() {
  if [[ -d /root/cafaye ]]; then
    log_info "Cafaye already exists, pulling latest..."
    cd /root/cafaye
    git pull origin master
  else
    log_info "Cloning Cafaye..."
    git clone https://github.com/kaka-ruto/cafaye /root/cafaye
    cd /root/cafaye
  fi

  log_ok "Cafaye ready"
}

# Change to cafaye directory
cd_cafaye() {
  cd /root/cafaye
}
