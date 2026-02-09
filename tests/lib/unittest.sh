#!/usr/bin/env bash
# Unittest.sh - A minitest-inspired test framework for bash
# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

FAILURES=()
TEST_COUNT=0

print_dot() { echo -n "."; }
print_fail() { echo -n "F"; }

report_failure() {
    local name=$1
    local detail=$2
    FAILURES+=("Failure:
$name
$detail")
}

assert_success() {
    local cmd="$1"
    local message="${2:-Command failed}"
    if ! eval "$cmd"; then
        print_fail
        report_failure "$name" "$message"
        return 1
    fi
}

assert_state_contains() {
    local json_file="$1"
    local key_path="$2"
    local expected_val="$3" # Optional, if missing just checks true
    local message="${4:-State check failed}"

    if [ -z "$expected_val" ]; then
        check=".$key_path == true"
    else
        check=".$key_path == $expected_val"
    fi

    if ! jq -e "$check" "$json_file" > /dev/null; then
        print_fail
        local content=$(cat "$json_file" 2>/dev/null)
        report_failure "$current_test_name" "$message: Expected $key_path to be $expected_val.\nContent:\n$content"
        return 1
    fi
}

run_test() {
    local test_func=$1
    local test_name="${2:-$test_func}"
    
    current_test_name="$test_name"
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if $test_func; then
        print_dot
    else
        # Failures handled inside assertions usually
        # If the function returns non-zero without assertion failure, treat as generic fail
        if [ ${#FAILURES[@]} -eq 0 ]; then
             print_fail
             report_failure "$test_name" "Test function returned non-zero exit code"
        fi
    fi
}

finish_tests() {
    echo ""
    echo ""
    echo "Finished."
    echo ""

    if [ ${#FAILURES[@]} -eq 0 ]; then
        echo -e "${GREEN}$TEST_COUNT runs, $TEST_COUNT assertions (approx), 0 failures, 0 errors${NC}"
        exit 0
    else
        echo -e "${RED}${#FAILURES[@]}) Failures:${NC}"
        for fail in "${FAILURES[@]}"; do
            echo -e "$fail"
            echo ""
        done
        echo -e "${RED}$TEST_COUNT runs, ${#FAILURES[@]} failures${NC}"
        exit 1
    fi
}
