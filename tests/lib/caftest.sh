#!/usr/bin/env bash
# Cafaye OS Test Harness (Legacy Adapter)
# This library provides helpers for our UNIT tests (Layer 0/1)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'

# State
FAILURES=()
TEST_COUNT=0
CURRENT_TEST=""

# --- Reporting ---
describe() {
    echo -e "${BLUE}Testing Suite: $1${NC}"
}

it() {
    local name="$1"
    shift
    CURRENT_TEST="$name"
    TEST_COUNT=$((TEST_COUNT + 1))
    
    # Run the test block
    if "$@"; then
        echo -n "."
    else
        echo -n "F"
        FAILURES+=("$CURRENT_TEST")
    fi
}

# --- Assertions ---

assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Expected '$expected', got '$actual'}"
    
    if [[ "$expected" != "$actual" ]]; then
        echo ""
        echo -e "${RED}Failure: $CURRENT_TEST${NC}"
        echo "  $msg"
        return 1
    fi
}

assert_json_path() {
    local file="$1"
    local path="$2"
    local expected="$3"
    
    # Use JQ to extract
    local actual
    actual=$(jq -r "$path // empty" "$file")
    
    if [[ "$actual" != "$expected" ]]; then
        echo ""
        echo -e "${RED}Failure: $CURRENT_TEST${NC}"
        echo "  JSON Check Failed: $path"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        echo "  File Content:"
        cat "$file"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo ""
        echo -e "${RED}Failure: $CURRENT_TEST${NC}"
        echo "  File not found: $file"
        return 1
    fi
}

# --- Hooks ---
setup() { :; }
teardown() { :; }

# --- Runner ---
run_suite() {
    echo ""
    if [ ${#FAILURES[@]} -eq 0 ]; then
        echo -e "${GREEN}All tests passed ($TEST_COUNT assertions)${NC}"
        exit 0
    else
        echo -e "${RED}${ #FAILURES[@]} failures encountered.${NC}"
        exit 1
    fi
}
