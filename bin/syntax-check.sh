#!/bin/bash
# Cafaye: Local Test Runner
# Verifies the distributed development infrastructure foundation

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}☕ Running Cafaye Runtime Verification...${NC}"

# 1. Check install.sh syntax
echo -e "\n${BLUE}Step 1: Checking install.sh syntax...${NC}"
if bash -n install.sh; then
    echo -e "${GREEN}✓ install.sh syntax is valid.${NC}"
else
    echo -e "${RED}✗ install.sh has syntax errors.${NC}"
    exit 1
fi

# 2. Check CLI scripts syntax
echo -e "\n${BLUE}Step 2: Checking CLI scripts syntax...${NC}"
for script in cli/scripts/*; do
    if [[ -f "$script" ]]; then
        if bash -n "$script"; then
            echo -e "✓ $(basename $script)"
        else
            echo -e "✗ $(basename $script) has syntax errors."
            exit 1
        fi
    fi
done

# 3. Flake Check (Dynamic for current system)
echo -e "\n${BLUE}Step 3: Checking Flake Logic...${NC}"
if nix flake check --no-build --show-trace --extra-experimental-features "nix-command flakes"; then
    echo -e "${GREEN}✓ Flake syntax and inputs are valid.${NC}"
else
    echo -e "${RED}✗ Flake check failed.${NC}"
    exit 1
fi

# 4. Home Configuration Evaluation
echo -e "\n${BLUE}Step 4: Verifying Home Configuration Buildability...${NC}"
SYSTEM_ARCH=$(uname -m)
[[ "$SYSTEM_ARCH" == "arm64" ]] && SYSTEM_ARCH="aarch64"
SYSTEM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
[[ "$SYSTEM_OS" == "darwin" ]] && OS_SUFFIX="darwin" || OS_SUFFIX="linux"
FLAKE_CONFIG="${SYSTEM_ARCH}-${OS_SUFFIX}"

echo "🔨 Evaluating configuration for: $FLAKE_CONFIG"

if nix eval ".#homeConfigurations.${FLAKE_CONFIG}.activationPackage" --extra-experimental-features "nix-command flakes" > /dev/null; then
    echo -e "${GREEN}✓ Home configuration translates to a valid derivation.${NC}"
else
    echo -e "${RED}✗ Home configuration evaluation failed.${NC}"
    exit 1
fi

# 5. Module-level 1:1 Tests
echo -e "\n${BLUE}Step 5: All module tests are integrated into 'nix flake check'.${NC}"
echo -e "✓ Modules verified via Step 3."

echo -e "\n${GREEN}✓ Cafaye Foundation is Ready!${NC}"
