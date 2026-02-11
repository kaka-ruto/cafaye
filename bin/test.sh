#!/bin/bash
# Cafaye Test Runner

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CAFAYE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$CAFAYE_DIR" || exit 1

export NIX_CONFIG="experimental-features = nix-command flakes"

# Detect system for nix targeting
SYSTEM_ARCH=$(uname -m)
[[ "$SYSTEM_ARCH" == "arm64" ]] && SYSTEM_ARCH="aarch64"
SYSTEM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
[[ "$SYSTEM_OS" == "darwin" ]] && OS_SUFFIX="darwin" || OS_SUFFIX="linux"
SYSTEM="${SYSTEM_ARCH}-${OS_SUFFIX}"

run_syntax() {
    echo -e "\n${BLUE}🔍 Running Syntax & Linting Checks...${NC}"
    bash bin/syntax-check.sh
    return $?
}

run_nix_all() {
    echo -e "\n${BLUE}❄️  Running All Behavioral Tests (Nix)...${NC}"
    nix build ".#checks.${SYSTEM}.all-modules" --no-link --show-trace
    return $?
}

run_nix_target() {
    # Translate slashes to dots for Nix attribute compatibility
    target="${1//\//.}"
    echo -e "\n${BLUE}❄️  Targeted Behavioral Test: $target...${NC}"
    nix build ".#checks.${SYSTEM}.\"${target}\"" --no-link --show-trace
    return $?
}

# --- Main Logic ---

command="$1"

case "$command" in
    "")
        # Default: Run everything
        run_syntax && run_nix_all
        ;;
    "--lint"|"--syntax")
        run_syntax
        ;;
    "--nix"|"nix")
        # Support 'caf test nix <target>' for legacy/explicit use
        if [[ -n "$2" ]]; then
            run_nix_target "$2"
        else
            run_nix_all
        fi
        ;;
    "--help"|"-h")
        echo "Usage: caf test [target] [options]"
        echo ""
        echo "Targets:"
        echo "  (none)             Run all linting and behavioral tests"
        echo "  <path>             Run specific test or suite (e.g. modules.languages.ruby)"
        echo ""
        echo "Options:"
        echo "  --lint, --syntax   Run only static analysis (fast)"
        echo "  --nix              Explicitly run all Nix behavioral tests"
        echo ""
        echo "Examples:"
        echo "  caf test modules.languages       # Run all language module tests"
        # shellcheck disable=SC2016
        echo '  caf test modules/languages/ruby  # Paths are automatically mapped to dots'
        echo "  caf test installer               # Run installer integration tests"
        ;;
    *)
        # Primary targeted path: 'caf test modules.languages.ruby'
        if [[ -n "$command" ]]; then
            run_nix_target "$command"
        else
            run_syntax && run_nix_all
        fi
        ;;
esac

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✅ Tests Passed!${NC}"
else
    echo -e "\n${RED}❌ Tests Failed.${NC}"
    exit 1
fi
