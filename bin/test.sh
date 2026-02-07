#!/bin/bash
# Cafaye OS: Local Test Runner (Verbose Version)
# Provides detailed feedback on Mac before pushing to GitHub.

# Use colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}☕ Running Verbose Local Cafaye OS Verification...${NC}"

# 1. Fast Evaluation Check
echo -e "\n${BLUE}Step 1: Evaluating Flake Configuration (Verbose)...${NC}"
# --show-trace and --print-build-logs (though build logs only apply if building)
if nix flake check --no-build --show-trace --extra-experimental-features "nix-command flakes"; then
    echo -e "${GREEN}✓ Logic and Syntax are sound.${NC}"
else
    echo -e "${RED}✗ Evaluation failed. See trace above.${NC}"
    exit 1
fi

# 2. Check User State Integration
echo -e "\n${BLUE}Step 2: Verifying System Buildability (Detailed Evaluation)...${NC}"
# We remove the &> /dev/null to show the derivation path and any warnings
if nix eval .#nixosConfigurations.cafaye.config.system.build.toplevel.drvPath --show-trace --extra-experimental-features "nix-command flakes"; then
    echo -e "${GREEN}✓ System configuration translates to a valid derivation.${NC}"
else
    echo -e "${RED}✗ System evaluation failed.${NC}"
    exit 1
fi

# 3. Instruction for Deep Testing
echo -e "\n${BLUE}Deep Testing Options:${NC}"
echo -e "To run actual VM boot tests (slow on Mac):"
echo -e "  $ devbox run test-full"

echo -e "\n${GREEN}✓ Ready to push to master!${NC}"
