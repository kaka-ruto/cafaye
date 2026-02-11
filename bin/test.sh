#!/bin/bash
# Cafaye Behavioral Test Runner
# Runs actual Nix evaluation tests for all modules

echo "🧪 Running Cafaye Module Tests..."
# Enable experimental features
export NIX_CONFIG="experimental-features = nix-command flakes"

# Run syntax check first
bash bin/syntax-check.sh || exit 1

echo -e "\n🔍 Running behavioral tests via 'nix flake check'..."
# On macOS, systems like x86_64-linux will be skipped, but we want to run what we can.
nix flake check --show-trace

if [[ $? -eq 0 ]]; then
    echo -e "\n✅ All module tests passed!"
else
    echo -e "\n❌ Some tests failed."
    exit 1
fi
