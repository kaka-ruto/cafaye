#!/usr/bin/env bats

setup() {
    export REPO_DIR="/tmp/cafaye-test-execute"
    rm -rf "$REPO_DIR"
    mkdir -p "$REPO_DIR/installer"
    cp "$BATS_TEST_DIRNAME/../../../installer/cafaye-execute.sh" "$REPO_DIR/installer/"
    cp "$BATS_TEST_DIRNAME/../../../install.sh" "$REPO_DIR/"
}

@test "cafaye-execute.sh contains required automation functions" {
    grep -q "create_installer_script()" "$REPO_DIR/installer/cafaye-execute.sh"
    grep -q "is_in_installer()" "$REPO_DIR/installer/cafaye-execute.sh"
    grep -q "run_in_installer()" "$REPO_DIR/installer/cafaye-execute.sh"
}

@test "cafaye-execute.sh prepares systemd service for kexec" {
    grep -q "cafaye-install.service" "$REPO_DIR/installer/cafaye-execute.sh"
    grep -q "multi-user.target.wants" "$REPO_DIR/installer/cafaye-execute.sh"
}

@test "cafaye-execute.sh uses correct paths for RAM OS" {
    grep -q 'REPO_DIR="/root/cafaye"' "$REPO_DIR/installer/cafaye-execute.sh"
    grep -q 'STATE_FILE="/cafaye-initial-state.json"' "$REPO_DIR/installer/cafaye-execute.sh"
}
