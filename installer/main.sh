#!/bin/bash
# Cafaye OS: VPS Installer Module
# This runs on the VPS during nixos-anywhere deployment
# to prepare the system for Cafaye OS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# This script is sourced by the NixOS installation process
# It runs in the initrd before the system is fully installed

# The actual installation happens via NixOS configuration
# This file is kept for reference and potential pre-install tasks

echo "Cafaye OS VPS Installer Module"
echo "This module runs during nixos-anywhere deployment"
