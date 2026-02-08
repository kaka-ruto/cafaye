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

# Run all tests
test_provider_detection
test_ssh_keys
test_stack_presets
test_error_handling
test_logging
test_network

echo ""
echo -e "${GREEN}All installer tests passed!${NC}"
