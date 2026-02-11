#!/usr/bin/env bats

setup() {
    export REPO_DIR="/tmp/cafaye-test-bootstrap"
    export STATE_FILE="/tmp/cafaye-initial-state.json"
    rm -rf "$REPO_DIR" "$STATE_FILE"
    mkdir -p "$REPO_DIR"
    cp -r "$BATS_TEST_DIRNAME/../../../." "$REPO_DIR/"
}

teardown() {
    rm -rf "$REPO_DIR" "$STATE_FILE"
}

@test "install.sh generates state file in non-interactive mode" {
    cd "$REPO_DIR"
    # Mock LSBLK to avoid real disk check if needed, but here we just check if it finds *something*
    # Or we can just run it and see if it fails on disk detection but still reaches state generation
    
    # We run it with --yes
    NON_INTERACTIVE=true ./install.sh --yes || true
    
    [ -f "/tmp/cafaye-initial-state.json" ]
}

@test "install.sh auto-detects disk in non-interactive mode" {
    cd "$REPO_DIR"
    ./install.sh --yes || true
    
    # Check if core.boot.grub_device is set in the state file
    grep -q "grub_device" "/tmp/cafaye-initial-state.json"
}

@test "install.sh skips wizard in non-interactive mode" {
    # If it didn't skip, it would hang on 'read' or 'gum'
    # We use a timeout to verify it completes or fails quickly
    run timeout 10s ./install.sh --yes
    [ "$status" -ne 124 ] # 124 is timeout
}
