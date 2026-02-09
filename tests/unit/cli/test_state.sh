#!/usr/bin/env bash
# Layer 1: CLI / State Tests
# Verifies caf-state-read and caf-state-write logic

source tests/lib/caftest.sh

describe "Layer 1: CLI State Management"

# Setup: Point to a fake state file
export STATE_FILE="/tmp/cafaye-cli-test-state.json"

setup() {
    # Initialize a clean state
    echo '{"test": {"boolean": false, "string": "initial"}}' > "$STATE_FILE"
}

it "writes boolean values correctly"
    bash cli/scripts/caf-state-write "test.boolean" "true"
    assert_json_path "$STATE_FILE" ".test.boolean" "true"

it "writes string values correctly"
    bash cli/scripts/caf-state-write "test.string" "updated"
    assert_json_path "$STATE_FILE" ".test.string" "updated"

it "reads values correctly"
    val=$(bash cli/scripts/caf-state-read "test.string")
    assert_equals "updated" "$val"

it "handles nested keys"
    bash cli/scripts/caf-state-write "new.nested.key" "123"
    assert_json_path "$STATE_FILE" ".new.nested.key" "123"

teardown() {
    rm -f "$STATE_FILE"
}

run_suite
