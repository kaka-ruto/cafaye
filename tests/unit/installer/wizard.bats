#!/usr/bin/env bats

load "../../lib/test_helper"

setup() {
    export STATE_FILE="$BATS_TMPDIR/cafaye-initial-state.json"
    export MOCK_GUM="$BATS_TMPDIR/gum"
    export MOCK_JQ="$BATS_TMPDIR/jq"
    export PATH="$BATS_TMPDIR:$PATH"
    
    # Create Mock Gum
    cat > "$MOCK_GUM" << 'EOF'
#!/usr/bin/env bash
cmd=$1
shift
case "$cmd" in
    confirm)
        if [[ "$MOCK_CONFIRM" == "no" ]]; then exit 1; else exit 0; fi
        ;;
    choose)
        echo -e "$MOCK_CHOICES"
        ;;
    *)
        echo "Gum called with unknown command: $cmd" >&2
        exit 1
        ;;
esac
EOF
    chmod +x "$MOCK_GUM"
    
    # Create JQ Shim (Prefer real jq)
    if command -v jq &> /dev/null; then
        ln -sf "$(command -v jq)" "$MOCK_JQ"
    else
        echo "Missing JQ - Test cannot run without jq on host for now"
    fi
}

teardown() {
    rm -f "$STATE_FILE" "$MOCK_GUM" "$MOCK_JQ"
}

@test "installer: generates minimal state" {
    export MOCK_CONFIRM="yes"
    export MOCK_CHOICES=""
    
    run bash installer/cafaye-wizard.sh
    [ "$status" -eq 0 ]
    
    run jq -r ".core.boot.grub_device" "$STATE_FILE"
    [ "$output" == "/dev/sda" ] # Assuming default lsblk output in mock env or real system
}

@test "installer: respects user cancellation" {
    export MOCK_CONFIRM="no"
    
    run bash installer/cafaye-wizard.sh
    [ "$status" -eq 1 ]
    
    [ ! -f "$STATE_FILE" ]
}

@test "installer: enables docker when selected" {
    export MOCK_CONFIRM="yes"
    export MOCK_CHOICES="🐳 Docker"
    
    run bash installer/cafaye-wizard.sh
    [ "$status" -eq 0 ]
    
    run jq -r ".dev_tools.docker" "$STATE_FILE"
    [ "$output" == "true" ]
}
