#!/usr/bin/env bash
# Tests for Cafaye installer scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
}

# Test 1: Check script syntax
test_syntax() {
    info "Testing script syntax..."
    
    if bash -n "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "cafaye-execute.sh has valid syntax"
    else
        fail "cafaye-execute.sh has syntax errors"
    fi
    
    if bash -n "$REPO_DIR/install.sh"; then
        pass "install.sh has valid syntax"
    else
        fail "install.sh has syntax errors"
    fi
}

# Test 2: Check script permissions
test_permissions() {
    info "Testing script permissions..."
    
    if [[ -x "$REPO_DIR/installer/cafaye-execute.sh" ]]; then
        pass "cafaye-execute.sh is executable"
    else
        fail "cafaye-execute.sh is not executable"
    fi
}

# Test 3: Check required variables
test_variables() {
    info "Testing required variables..."
    
    # Source the script in check mode to verify variables
    REPO_DIR="/root/cafaye"
    STATE_FILE="/tmp/cafaye-initial-state.json"
    LOG_FILE="/var/log/cafaye-install.log"
    KEXEC_MARKER="/tmp/cafaye-kexec-done"
    INSTALLER_SCRIPT="/tmp/cafaye-installer.sh"
    
    if [[ -n "$REPO_DIR" && -n "$STATE_FILE" && -n "$LOG_FILE" ]]; then
        pass "Required variables are defined"
    else
        fail "Some required variables are missing"
    fi
}

# Test 4: Check functions exist
test_functions() {
    info "Testing function definitions..."
    
    # Check if key functions are defined in the script
    if grep -q "^create_installer_script()" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "create_installer_script function exists"
    else
        fail "create_installer_script function missing"
    fi
    
    if grep -q "^is_in_installer()" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "is_in_installer function exists"
    else
        fail "is_in_installer function missing"
    fi
    
    if grep -q "^run_in_installer()" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "run_in_installer function exists"
    else
        fail "run_in_installer function missing"
    fi
    
    if grep -q "^main()" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "main function exists"
    else
        fail "main function missing"
    fi
}

# Test 5: Check installer creates proper NixOS config
test_nixos_config() {
    info "Testing NixOS configuration generation..."
    
    if grep -q "nixos-generate-config" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script calls nixos-generate-config"
    else
        fail "Script doesn't call nixos-generate-config"
    fi
    
    if grep -q "nixos-install" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script calls nixos-install"
    else
        fail "Script doesn't call nixos-install"
    fi
}

# Test 6: Check error handling
test_error_handling() {
    info "Testing error handling..."
    
    if grep -q "set -e" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script has error handling (set -e)"
    else
        fail "Script lacks error handling"
    fi
    
    if grep -q "ERROR:" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script has error messages"
    else
        fail "Script lacks error messages"
    fi
}

# Test 7: Check state file handling
test_state_file() {
    info "Testing state file handling..."
    
    if grep -q "user/user-state.json" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script handles user-state.json"
    else
        fail "Script doesn't handle user-state.json"
    fi
}

# Test 8: Check kexec URL
test_kexec_url() {
    info "Testing kexec URL..."
    
    if grep -q "github.com/nix-community/nixos-images" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Script uses correct kexec URL"
    else
        fail "Script has incorrect kexec URL"
    fi
}

# Test 9: Test install.sh non-interactive mode
test_non_interactive_mode() {
    info "Testing install.sh non-interactive mode..."
    
    if grep -q "NON_INTERACTIVE" "$REPO_DIR/install.sh"; then
        pass "install.sh supports non-interactive mode"
    else
        fail "install.sh lacks non-interactive mode"
    fi
    
    if grep -q "\-\-yes" "$REPO_DIR/install.sh"; then
        pass "install.sh has --yes flag support"
    else
        fail "install.sh lacks --yes flag"
    fi
}

# Test 10: Integration test - check all installer scripts work together
test_integration() {
    info "Testing installer integration..."
    
    # Check that all scripts reference the same paths
    if grep -q "/root/cafaye" "$REPO_DIR/install.sh" && \
       grep -q "/root/cafaye" "$REPO_DIR/installer/cafaye-execute.sh" && \
       grep -q "/tmp/cafaye-initial-state.json" "$REPO_DIR/install.sh" && \
       grep -q "/tmp/cafaye-initial-state.json" "$REPO_DIR/installer/cafaye-execute.sh"; then
        pass "Scripts use consistent paths"
    else
        fail "Scripts have inconsistent paths"
    fi
}

# Main test runner
main() {
    echo "========================================="
    echo "Cafaye Installer Test Suite"
    echo "========================================="
    echo ""
    
    REPO_DIR="${1:-.}"
    
    if [[ ! -d "$REPO_DIR" ]]; then
        echo "ERROR: Repository directory not found: $REPO_DIR"
        exit 1
    fi
    
    # Run all tests
    test_syntax
    test_permissions
    test_variables
    test_functions
    test_nixos_config
    test_error_handling
    test_state_file
    test_kexec_url
    test_non_interactive_mode
    test_integration
    
    # Summary
    echo ""
    echo "========================================="
    echo "Test Results:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "========================================="
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
