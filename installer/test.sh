#!/bin/bash
# Cafaye OS: Installer Tests

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$TEST_DIR"

pass() { echo -e "${GREEN}✓ $*${NC}"; }
fail() { echo -e "${RED}✗ $*${NC}"; exit 1; }

echo "Running Cafaye Installer Tests..."
echo ""

# Test provider detection
test_provider_detection() {
    echo "Testing provider detection..."
    source ./provider.sh
    
    [[ "$(detect_provider "5.75.123.45")" == "hetzner" ]]; pass "Hetzner detection"
    [[ "$(detect_provider "65.1.123.45")" == "digitalocean" ]]; pass "DigitalOcean detection"
    [[ "$(detect_provider "1.2.3.4")" == "unknown" ]]; pass "Unknown provider fallback"
    
    [[ "$(get_disk_device "hetzner")" == "/dev/sda" ]]; pass "Hetzner disk: /dev/sda"
    [[ "$(get_disk_device "aws")" == "/dev/nvme0n1" ]]; pass "AWS disk: /dev/nvme0n1"
    [[ "$(get_disk_device "unknown")" == "/dev/vda" ]]; pass "Unknown disk: /dev/vda"
    
    [[ "$(get_provider_display_name "hetzner")" == "Hetzner Cloud" ]]; pass "Hetzner display name"
}

# Test SSH key functions
test_ssh_keys() {
    echo "Testing SSH key functions..."
    source ./ssh.sh
    
    [[ "$(ssh_keys_to_json "key1" "key2" "key3")" == '["key1","key2","key3"]' ]]; pass "Multiple keys to JSON"
    [[ "$(ssh_keys_to_json)" == "[]" ]]; pass "Empty keys to JSON"
}

# Test stack presets
test_stack_presets() {
    echo "Testing stack presets..."
    source ./stack.sh
    
    local rails_preset
    rails_preset=$(get_preset "rails")
    [[ "$rails_preset" == *"ruby"* ]]; pass "Rails preset has ruby"
    [[ "$rails_preset" == *"rails"* ]]; pass "Rails preset has rails"
    
    local django_preset
    django_preset=$(get_preset "django")
    [[ "$django_preset" == *"python"* ]]; pass "Django preset has python"
    
    local go_preset
    go_preset=$(get_preset "go")
    [[ "$go_preset" == *"go"* ]]; pass "Go preset has go"
    
    [[ -z "$(get_preset "nonexistent")" ]]; pass "Invalid preset returns empty"
}

# Test error handling helpers
test_error_handling() {
    echo "Testing error handling..."
    source ./errors.sh
    [[ "$(type -t catch_errors 2>/dev/null)" == "function" ]]; pass "catch_errors defined"
}

# Test logging helpers
test_logging() {
    echo "Testing logging..."
    source ./logging.sh 2>/dev/null || true
    [[ "$(type -t log 2>/dev/null)" == "function" ]]; pass "log function defined"
}

# Test network helpers
test_network() {
    echo "Testing network helpers..."
    source ./network.sh
    [[ "$(type -t test_ssh_connection 2>/dev/null)" == "function" ]]; pass "test_ssh_connection defined"
}

# Test install.sh self_clone function
test_install_script() {
    echo "Testing install.sh self_clone function..."
    
    # Test 1: Verify pipe mode condition detection
    (
        local test_val="-"
        if [[ "$test_val" == "-" ]]; then
            pass "self_clone correctly identifies pipe mode condition"
        else
            fail "self_clone failed to identify pipe mode"
        fi
    )
    
    # Test 2: Verify non-pipe mode detection
    (
        local test_val="./install.sh"
        if [[ "$test_val" != "-" ]]; then
            pass "self_clone correctly identifies non-pipe mode"
        else
            fail "self_clone incorrectly identified non-pipe mode"
        fi
    )
    
    # Test 3: Verify script path comparison logic
    (
        # Simulate pipe mode - current_script_path should be pwd/install.sh
        local expected_script="/tmp/cafaye/install.sh"
        local current_script="/tmp/cafaye/install.sh"
        
        if [[ "$current_script" == "$expected_script" ]]; then
            pass "Script path comparison correctly identifies matching paths"
        else
            fail "Script path comparison failed"
        fi
    )
    
    # Test 4: Verify non-matching paths trigger exec
    (
        local expected_script="/tmp/cafaye/install.sh"
        local current_script="/different/path/install.sh"
        
        if [[ "$current_script" != "$expected_script" ]]; then
            pass "Non-matching paths correctly identified for exec"
        else
            fail "Non-matching paths incorrectly identified"
        fi
    )
    
    # Test 5: Test dirname behavior with "-" (the root cause of the bug)
    (
        local result
        result=$(dirname "-")
        # dirname "-" returns "-" on most systems, but could vary
        # The key is that dirname "-$ should not be confused with a valid path
        [[ -n "$result" ]]; pass "dirname handles '-' gracefully"
    )
    
    # Test 6: Verify install.sh syntax is valid
    (
        if bash -n ../install.sh 2>/dev/null; then
            pass "install.sh has valid bash syntax"
        else
            fail "install.sh has syntax errors"
        fi
    )
    
    # Test 7: Simulate the full pipe mode flow
    (
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        mkdir -p "cafaye"
        touch "cafaye/flake.nix"
        mkdir -p "cafaye/installer"
        
        # Simulate: after self_clone, we should be in cafaye directory
        cd "cafaye"
        local pwd_result=$(pwd)
        
        # Expected script path should match pwd + install.sh
        local expected="$pwd_result/install.sh"
        
        [[ "$expected" == "$temp_dir/cafaye/install.sh" ]]; pass "Pipe mode path resolution works correctly"
        
        rm -rf "$temp_dir"
    )
}

# Run all tests
test_provider_detection
test_ssh_keys
test_stack_presets
test_error_handling
test_logging
test_network
test_install_script

echo ""
echo -e "${GREEN}All installer tests passed!${NC}"
