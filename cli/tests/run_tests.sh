#!/usr/bin/env bash
# Layer 1: Orchestration/CLI Logic Tests
# Tests `caf-state-read` and `caf-state-write`

set -e

REPO_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_DIR"

source tests/lib/unittest.sh

TEST_STATE_FILE="/tmp/cafaye-cli-test-user-state.json"
export STATE_FILE="$TEST_STATE_FILE" # Assuming scripts respect this or we manually overwrite /etc logic...
# Wait, caf-state-write currently hardcodes /etc or git root.
# Let's check `caf-state-write` logic again:
# if [[ ! -f "$STATE_FILE" ]]; then STATE_FILE=...git root...

# So if we copy `user-state.json.example` to `user/user-state.json` (git root), it will use it.
# But we don't want to mess up real user state if developing locally.
# We should update `caf-state-write` to respect an env var for testing.

setup() {
    cp user/user-state.json.example user/user-state.json.test
    export STATE_FILE="$(pwd)/user/user-state.json.test"
}

teardown() {
    rm -f user/user-state.json.test
}

test_write_boolean() {
    # 1. Write bool
    if ! bash cli/scripts/caf-state-write "test.boolean" "true"; then return 1; fi
    
    # 2. Verify
    if ! grep '"test":' "$STATE_FILE" > /dev/null; then return 1; fi
    if ! grep '"boolean": true' "$STATE_FILE" > /dev/null; then return 1; fi
}

test_write_string() {
    # 1. Write string
    if ! bash cli/scripts/caf-state-write "test.string" "hello"; then return 1; fi
    
    # 2. Verify
    if ! grep '"string": "hello"' "$STATE_FILE" > /dev/null; then return 1; fi
}

test_read_value() {
    # Setup
    echo '{"test": {"read": "success"}}' > "$STATE_FILE"
    
    # Read
    val=$(bash cli/scripts/caf-state-read "test.read")
    if [[ "$val" != "success" ]]; then return 1; fi
}

# --- Execution ---
echo "Running CLI Logic Tests (Layer 1)..."

setup
run_test test_write_boolean "Write Boolean"
run_test test_write_string "Write String"
run_test test_read_value "Read Value"
teardown

finish_tests
