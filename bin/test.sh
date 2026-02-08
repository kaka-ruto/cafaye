#!/bin/bash
# Cafaye OS: Local Test Runner (Verbose Version)
# Provides detailed feedback on Mac before pushing to GitHub.

# Use colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}☕ Running Verbose Local Cafaye OS Verification...${NC}"

# 1. Check install.sh syntax
echo -e "\n${BLUE}Step 1: Checking install.sh syntax...${NC}"
if bash -n install.sh; then
    echo -e "${GREEN}✓ install.sh syntax is valid.${NC}"
else
    echo -e "${RED}✗ install.sh has syntax errors.${NC}"
    exit 1
fi

# 2. Check installer syntax and run tests
echo -e "\n${BLUE}Step 2: Checking installer syntax...${NC}"
for helper in installer/*.sh; do
    if [[ -f "$helper" && "$(basename "$helper")" != "test.sh" ]]; then
        if bash -n "$helper" 2>/dev/null; then
            echo -e "✓ $(basename $helper)"
        else
            echo -e "✗ $(basename $helper) has syntax errors."
            exit 1
        fi
    fi
done

# 2b. Run installer tests
echo -e "\n${BLUE}Step 2b: Running installer tests...${NC}"
# Use bash tests - works everywhere without dependencies
if bash installer/test.sh; then
    echo -e "${GREEN}✓ All installer tests passed${NC}"
else
    echo -e "${RED}✗ Installer tests failed${NC}"
    exit 1
fi

# 3. Check all CLI scripts syntax
echo -e "\n${BLUE}Step 3: Checking CLI scripts syntax...${NC}"
for script in cli/scripts/*; do
    if [[ -x "$script" ]]; then
        if bash -n "$script"; then
            echo -e "✓ $(basename $script)"
        else
            echo -e "✗ $(basename $script) has syntax errors."
            exit 1
        fi
    fi
done

# 4. Fast Evaluation Check
echo -e "\n${BLUE}Step 4: Evaluating Flake Configuration...${NC}"
# --show-trace and --print-build-logs (though build logs only apply if building)
if nix flake check --no-build --show-trace --extra-experimental-features "nix-command flakes"; then
    echo -e "${GREEN}✓ Logic and Syntax are sound.${NC}"
else
    echo -e "${RED}✗ Evaluation failed. See trace above.${NC}"
    exit 1
fi

# 5. Check User State Integration
echo -e "\n${BLUE}Step 5: Verifying System Buildability...${NC}"
# We remove the &> /dev/null to show the derivation path and any warnings
if nix eval .#nixosConfigurations.cafaye.config.system.build.toplevel.drvPath --show-trace --extra-experimental-features "nix-command flakes"; then
    echo -e "${GREEN}✓ System configuration translates to a valid derivation.${NC}"
else
    echo -e "${RED}✗ System evaluation failed.${NC}"
    exit 1
fi

# 6. Instruction for Deep Testing
echo -e "\n${BLUE}Deep Testing Options:${NC}"
echo -e "To run actual VM boot tests (slow on Mac):"
echo -e "  $ devbox run test-full"

echo -e "\n${GREEN}✓ Ready to push to master!${NC}"

echo -e "\n${BLUE}To run full VM integration tests:${NC}"
echo -e "  $ devbox run test-full"
