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

run_unit() {
    echo -e "\n${BLUE}🧪 Running unit tests (Bats)...${NC}"
    if ! command -v bats >/dev/null 2>&1; then
        echo "⚠️  bats not found, skipping unit tests."
        return 0
    fi
    bats tests/unit
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

run_remote() {
    local target="$1"
    # Get VPS info from vps_deploy script if available, or use defaults
    VPS_IP="34.10.103.233"
    SSH_USER="kaka"
    SSH_KEY="$HOME/.ssh/cafaye"

    echo -e "\n${BLUE}☁️  Running Remote Test on Forge: $VPS_IP${NC}"
    
    # Sync current state
    echo "📦 Syncing to forge..."
    rsync -avz --exclude '.git' --exclude '.devbox' --exclude 'result' \
          -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
          ./ $SSH_USER@$VPS_IP:~/cafaye-test-forge/
    
    # Run test command on forge
    echo "🚀 Executing test on forge..."
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$VPS_IP" "cd ~/cafaye-test-forge && ./bin/test.sh $target"
    return $?
}

run_real_world_single_vm() {
    echo -e "\n${BLUE}☁️  Running single-VM real-world audit...${NC}"
    INSTANCE_NAME="${INSTANCE_NAME:-cafaye-vps-test}" \
    ZONE="${ZONE:-us-central1-a}" \
    bash tests/integration/real-world/single-vm-audit.sh
}

# --- Main Logic ---

TARGET=""
REMOTE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --remote) REMOTE=true ;;
        --lint|--syntax) TARGET="--lint" ;;
        --nix|nix) # Support 'caf test nix <target>'
            if [[ -n "$2" && "$2" != "--remote" ]]; then
                TARGET="$2"
                shift
            else
                TARGET="all"
            fi
            ;;
        --help|-h)
            echo "Usage: caf test [target] [--remote]"
            echo ""
            echo "Options:"
            echo "  --remote           Run the test on the remote GCP forge"
            echo "  --lint, --syntax   Run only static analysis"
            echo "  --nix              Run all Nix behavioral tests"
            echo ""
            echo "Targets:"
            echo "  modules.languages.ruby"
            echo "  installer"
            echo "  real-world"
            exit 0
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
            fi
            ;;
    esac
    shift
done

if [[ "$REMOTE" == "true" ]]; then
    run_remote "$TARGET"
else
    case "$TARGET" in
        "--lint")
            run_syntax
            ;;
        "real-world")
            run_real_world_single_vm
            ;;
        "unit")
            run_unit
            ;;
        "all"|"")
            run_syntax && run_unit && run_nix_all
            ;;
        *)
            run_nix_target "$TARGET"
            ;;
    esac
fi

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✅ Tests Passed!${NC}"
else
    echo -e "\n${RED}❌ Tests Failed.${NC}"
    exit 1
fi
