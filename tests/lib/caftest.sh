#!/usr/bin/env bash
# Cafaye OS Test Harness (Legacy Adapter)
# This library provides helpers for our UNIT tests (Layer 0/1)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'

# State
FAILURES_FILE="/tmp/cafaye-test-failures"
echo "0" > "$FAILURES_FILE"
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
    
    # Run the test block in a subshell to trap exit codes
    (
        set -e
        # Run Setup Hook if defined
        if declare -f setup > /dev/null; then setup; fi
        
        "$@"
        
        # Run Teardown Hook if defined
        if declare -f teardown > /dev/null; then teardown; fi
    )
    code=$?
    
    if [[ $code -eq 0 ]]; then
        echo -n "."
    else
        echo -n "F"
        # Since we are essentially in the main shell here (the subshell just ran the command),
        # we can safely update the file.
        count=$(cat "$FAILURES_FILE")
        echo $((count + 1)) > "$FAILURES_FILE"
        echo "##FAILURE##:$CURRENT_TEST (Exit Code: $code)" >> "$FAILURES_FILE.log"
    fi
}

# --- Runner ---
run_suite() {
    echo ""
    failures=$(cat "$FAILURES_FILE")
    
    if [[ "$failures" == "0" ]]; then
        echo -e "${GREEN}All tests passed ($TEST_COUNT assertions)${NC}"
        rm -f "$FAILURES_FILE" "$FAILURES_FILE.log"
        exit 0
    else
        echo -e "${RED}$failures failures encountered.${NC}"
        if [[ -f "$FAILURES_FILE.log" ]]; then
            grep "##FAILURE##" "$FAILURES_FILE.log" | cut -d: -f2-
        fi
        rm -f "$FAILURES_FILE" "$FAILURES_FILE.log"
        exit 1
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

