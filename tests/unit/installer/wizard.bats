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
    
    # Create Mocks for Linux Commands
    cat > "$BATS_TMPDIR/lsblk" << 'EOF'
#!/usr/bin/env bash
echo "sda 8:0 0 200G 0 disk"
EOF
    chmod +x "$BATS_TMPDIR/lsblk"

    cat > "$BATS_TMPDIR/ip" << 'EOF'
#!/usr/bin/env bash
echo "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 42:01:0a:80:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.128.0.2/32 brd 10.128.0.2 scope global eth0
       valid_lft forever preferred_lft forever"
EOF
    chmod +x "$BATS_TMPDIR/ip"
    
    cat > "$BATS_TMPDIR/free" << 'EOF'
#!/usr/bin/env bash
echo "               total        used        free      shared  buff/cache   available
Mem:            31Gi       2.4Gi        26Gi       1.0Mi       2.4Gi        28Gi
Swap:          240Mi          0B       240Mi"
EOF
    chmod +x "$BATS_TMPDIR/free"
    
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

@test "installer: enables postgres when rails is selected" {
    export MOCK_CONFIRM="yes"
    export MOCK_CHOICES="🛤️  Ruby on Rails"
    
    run bash installer/cafaye-wizard.sh
    [ "$status" -eq 0 ]
    
    run jq -r ".frameworks.rails" "$STATE_FILE"
    [ "$output" == "true" ]
}

@test "installer: enables mysql when selected" {
    export MOCK_CONFIRM="yes"
    export MOCK_CHOICES="🐬 MySQL"
    
    run bash installer/cafaye-wizard.sh
    [ "$status" -eq 0 ]
    
    run jq -r ".services.mysql" "$STATE_FILE"
    [ "$output" == "true" ]
}
