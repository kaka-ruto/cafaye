#!/usr/bin/env bats

load "../../lib/test_helper"

setup() {
    export CAFAYE_DIR="$BATS_TMPDIR/cafaye-proj-test"
    mkdir -p "$CAFAYE_DIR"
    export PROJECTS_FILE="$CAFAYE_DIR/projects.json"
    echo '{"current":null,"projects":[]}' > "$PROJECTS_FILE"
}

teardown() {
    rm -rf "$CAFAYE_DIR"
}

@test "caf project create: adds a new project" {
    run cli/scripts/caf-project create "test-project" --path "/tmp/test-proj"
    [ "$status" -eq 0 ]
    
    run jq -r '.projects[0].name' "$PROJECTS_FILE"
    [ "$output" == "test-project" ]
    
    run jq -r '.current' "$PROJECTS_FILE"
    [ "$output" == "test-project" ]
}

@test "caf project list: displays projects" {
    cli/scripts/caf-project create "p1" --path "/tmp/p1"
    cli/scripts/caf-project create "p2" --path "/tmp/p2"
    
    run cli/scripts/caf-project list
    [ "$status" -eq 0 ]
    [[ "$output" == *"p1"* ]]
    [[ "$output" == *"p2"* ]]
}

@test "caf project delete: removes a project" {
    cli/scripts/caf-project create "to-delete" --path "/tmp/to-del"
    
    run cli/scripts/caf-project delete "to-delete"
    [ "$status" -eq 0 ]
    
    run jq -r '.projects | length' "$PROJECTS_FILE"
    [ "$output" -eq 0 ]
}

@test "caf project switch: changes current project" {
    cli/scripts/caf-project create "p1" --path "/tmp/p1"
    cli/scripts/caf-project create "p2" --path "/tmp/p2"
    
    run cli/scripts/caf-project switch "p1"
    [ "$status" -eq 0 ]
    
    run jq -r '.current' "$PROJECTS_FILE"
    [ "$output" == "p1" ]
}
