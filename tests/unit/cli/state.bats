#!/usr/bin/env bats

load "../../lib/test_helper"

setup() {
    # Set STATE_FILE to a temporary location
    export STATE_FILE="$BATS_TMPDIR/cafaye-cli-test-state.json"
    echo '{"test": {"boolean": false, "string": "initial"}}' > "$STATE_FILE"
}

teardown() {
    rm -f "$STATE_FILE"
}

@test "caf-state-write: updates boolean values" {
    run cli/scripts/caf-state-write "test.boolean" "true"
    [ "$status" -eq 0 ]
    
    run jq -r ".test.boolean" "$STATE_FILE"
    [ "$output" == "true" ]
}

@test "caf-state-write: updates string values" {
    run cli/scripts/caf-state-write "test.string" "updated"
    [ "$status" -eq 0 ]
    
    run jq -r ".test.string" "$STATE_FILE"
    [ "$output" == "updated" ]
}

@test "caf-state-read: retrieves values correctly" {
    run cli/scripts/caf-state-read "test.string"
    [ "$status" -eq 0 ]
    [ "$output" == "initial" ]
}

@test "caf-state-write: handles nested keys" {
    run cli/scripts/caf-state-write "new.nested.key" "123"
    [ "$status" -eq 0 ]
    
    run jq -r ".new.nested.key" "$STATE_FILE"
    [ "$output" == "123" ]
}
