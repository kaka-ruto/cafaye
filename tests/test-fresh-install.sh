#!/bin/bash
set -euo pipefail

# Cafaye OS Fresh Install Test
# Tests the installer on a clean system (VPS or VM)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Test Cafaye installer on a fresh system.

OPTIONS:
    --vps NAME          Test on a new GCP VPS instance
    --existing HOST     Test on existing host via SSH
    --local            Test locally (WARNING: modifies system)
    --cleanup          Clean up test VPS after completion
    -h, --help         Show this help

EXAMPLES:
    # Test on new VPS (auto-cleanup)
    $0 --vps test-install --cleanup

    # Test on existing server
    $0 --existing user@hostname

    # Local test (use with caution!)
    $0 --local
EOF
}

VPS_NAME=""
EXISTING_HOST=""
LOCAL_TEST=false
CLEANUP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vps)
            VPS_NAME="$2"
            shift 2
            ;;
        --existing)
            EXISTING_HOST="$2"
            shift 2
            ;;
        --local)
            LOCAL_TEST=true
            shift
            ;;
        --cleanup)
            CLEANUP=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

log() {
    echo -e "${BLUE}[TEST]${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*"
}

run_test_suite() {
    local host="$1"
    local ssh_prefix="$2"
    
    log "Running test suite on $host..."
    
    # Test 1: Clone repository
    log "Test 1: Cloning repository..."
    $ssh_prefix "rm -rf /tmp/cafaye-test && git clone --depth 1 https://github.com/cafaye/cafaye.git /tmp/cafaye-test"
    success "Repository cloned"
    
    # Test 2: Run installer (non-interactive)
    log "Test 2: Running installer (non-interactive)..."
    $ssh_prefix "cd /tmp/cafaye-test && ./install.sh --yes" || {
        error "Installer failed"
        $ssh_prefix "cat ~/.config/cafaye/logs/install.log" || true
        return 1
    }
    success "Installer completed"
    
    # Test 3: Verify installation
    log "Test 3: Verifying installation..."
    
    # Check directory structure
    $ssh_prefix "test -d ~/.config/cafaye" || { error "Config directory missing"; return 1; }
    success "Config directory exists"
    
    $ssh_prefix "test -f ~/.config/cafaye/environment.json" || { error "environment.json missing"; return 1; }
    success "environment.json exists"
    
    $ssh_prefix "test -f ~/.config/cafaye/settings.json" || { error "settings.json missing"; return 1; }
    success "settings.json exists"
    
    # Check CLI availability
    $ssh_prefix "command -v caf" || { error "caf command not found"; return 1; }
    success "caf command available"
    
    # Test 4: Run basic commands
    log "Test 4: Testing basic commands..."
    
    $ssh_prefix "caf status" || { error "caf status failed"; return 1; }
    success "caf status works"
    
    $ssh_prefix "caf-system-doctor" || { error "caf-system-doctor failed"; return 1; }
    success "caf-system-doctor works"
    
    # Test 5: Test idempotency (re-run installer)
    log "Test 5: Testing installer idempotency..."
    $ssh_prefix "cd /tmp/cafaye-test && ./install.sh --yes" || {
        error "Idempotent install failed"
        return 1
    }
    success "Installer is idempotent"
    
    # Test 6: Test uninstaller
    log "Test 6: Testing uninstaller..."
    $ssh_prefix "cd ~/.config/cafaye && ./uninstall.sh --yes" || {
        error "Uninstaller failed"
        return 1
    }
    success "Uninstaller works"
    
    # Verify cleanup
    $ssh_prefix "test ! -d ~/.config/cafaye" || { error "Config directory still exists after uninstall"; return 1; }
    success "Uninstall cleanup successful"
    
    # Verify backup exists
    $ssh_prefix "ls -d ~/.config/cafaye.uninstall-backup.* | head -1" || { error "Uninstall backup missing"; return 1; }
    success "Uninstall backup created"
    
    log "All tests passed! ✨"
    return 0
}

# Main execution
if [[ "$LOCAL_TEST" == "true" ]]; then
    echo -e "${RED}WARNING: This will modify your local system!${NC}"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    
    run_test_suite "localhost" ""
    
elif [[ -n "$EXISTING_HOST" ]]; then
    log "Testing on existing host: $EXISTING_HOST"
    run_test_suite "$EXISTING_HOST" "ssh $EXISTING_HOST"
    
elif [[ -n "$VPS_NAME" ]]; then
    log "Creating test VPS: $VPS_NAME"
    
    # Create VPS
    cd "$REPO_ROOT"
    ./cli/scripts/caf-vps create "$VPS_NAME" || {
        error "Failed to create VPS"
        exit 1
    }
    
    # Get VPS IP
    VPS_IP=$(./cli/scripts/caf-vps list | grep "$VPS_NAME" | awk '{print $2}')
    if [[ -z "$VPS_IP" ]]; then
        error "Could not determine VPS IP"
        exit 1
    fi
    
    log "VPS created: $VPS_IP"
    
    # Wait for SSH
    log "Waiting for SSH..."
    for i in {1..30}; do
        if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "root@$VPS_IP" "echo ok" &>/dev/null; then
            success "SSH ready"
            break
        fi
        sleep 2
    done
    
    # Run tests
    run_test_suite "$VPS_IP" "ssh -o StrictHostKeyChecking=no root@$VPS_IP"
    TEST_RESULT=$?
    
    # Cleanup if requested
    if [[ "$CLEANUP" == "true" ]]; then
        log "Cleaning up VPS..."
        ./cli/scripts/caf-vps delete "$VPS_NAME" --yes
        success "VPS deleted"
    else
        log "VPS preserved: $VPS_NAME ($VPS_IP)"
        log "To delete: ./cli/scripts/caf-vps delete $VPS_NAME"
    fi
    
    exit $TEST_RESULT
    
else
    error "No test target specified"
    usage
    exit 1
fi
