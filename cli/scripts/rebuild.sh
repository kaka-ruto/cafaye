#!/bin/bash

# Rebuilds the system using the current flake
# Usage: caf-system-rebuild

echo "🚀 Starting Cafaye OS Rebuild..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "⚠️  Detected macOS. Rebuild is only available on NixOS."
    echo "Evaluating local configuration instead..."
    nix flake check --show-trace
else
    sudo nixos-rebuild switch --flake .#cafaye --show-trace
fi
