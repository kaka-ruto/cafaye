#!/usr/bin/env bats

# Cafaye OS: E2E Orchestration Logic Test
# This tests the "Self-Driving" flow from install.sh through to cafaye-execute.sh preparation.

setup() {
    export REPO_DIR="${BATS_TMPDIR}/cafaye"
    mkdir -p "$REPO_DIR/installer"
    mkdir -p "$REPO_DIR/user"
    cp "${BATS_TEST_DIRNAME}/../../../install.sh" "$REPO_DIR/"
    cp "${BATS_TEST_DIRNAME}/../../../installer/cafaye-wizard.sh" "$REPO_DIR/installer/"
    cp "${BATS_TEST_DIRNAME}/../../../installer/cafaye-execute.sh" "$REPO_DIR/installer/"
    cp "${BATS_TEST_DIRNAME}/../../../user/user-state.json.example" "$REPO_DIR/user/user-state.json.example"
    
    # Mock system commands
    mkdir -p "${BATS_TMPDIR}/bin"
    export PATH="${BATS_TMPDIR}/bin:$PATH"
    
    cat > "${BATS_TMPDIR}/bin/lsblk" <<EOF
#!/bin/bash
echo "vda 254:0 0 50G 0 disk"
EOF
    cat > "${BATS_TMPDIR}/bin/gum" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "${BATS_TMPDIR}/bin/curl" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "${BATS_TMPDIR}/bin/git" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "${BATS_TMPDIR}/bin/systemctl" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "${BATS_TMPDIR}/bin/hostname" <<EOF
#!/bin/bash
echo "127.0.0.1"
EOF

    chmod +x "${BATS_TMPDIR}/bin/"*
}

teardown() {
    rm -rf "$REPO_DIR"
    rm -rf "${BATS_TMPDIR}/bin"
}

@test "full flow: install.sh generates state and launches execute.sh" {
    cd "$REPO_DIR"
    
    # Mock nohup to avoid background execution during test
    cat > "${BATS_TMPDIR}/bin/nohup" <<EOF
#!/bin/bash
"\$@"
EOF
    chmod +x "${BATS_TMPDIR}/bin/nohup"

    # Patch install.sh to avoid actual network/systemd changes
    sed -i 's/apt-get /true /g' install.sh
    sed -i 's/yum /true /g' install.sh
    sed -i 's/ssh-keygen /true /g' install.sh
    sed -i 's/sed -i/true /g' install.sh
    
    run bash install.sh --yes
    [ "$status" -eq 0 ]
    
    # Check log file
    if [ ! -f "/var/log/cafaye-install.log" ]; then
        echo "Log file /var/log/cafaye-install.log missing!"
        exit 1
    fi
    grep -q "Cafaye OS" "/var/log/cafaye-install.log" || {
        echo "Log content follows:"
        cat "/var/log/cafaye-install.log"
        exit 1
    }

    # Check state file
    [ -f "/tmp/cafaye-initial-state.json" ]
    grep -q "/dev/vda" "/tmp/cafaye-initial-state.json"
}

@test "cafaye-execute.sh: prepares kexec overlay and systemd service" {
    export STATE_FILE="/tmp/cafaye-initial-state.json"
    echo '{"core": {"boot": {"grub_device": "/dev/vda"}}}' > "$STATE_FILE"
    
    # Mock cpio and gzip to avoid actual archive creation
    cat > "${BATS_TMPDIR}/bin/cpio" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "${BATS_TMPDIR}/bin/gzip" <<EOF
#!/bin/bash
exit 0
EOF
    chmod +x "${BATS_TMPDIR}/bin/cpio" "${BATS_TMPDIR}/bin/gzip"

    # Patch cafaye-execute.sh to skip kexec reboot and heavy downloads
    sed -i 's/curl /true /g' installer/cafaye-execute.sh
    sed -i 's/tar /true /g' installer/cafaye-execute.sh
    sed -i 's/.\/kexec -e/echo KEXEC_SUCCESS/' installer/cafaye-execute.sh
    
    run bash installer/cafaye-execute.sh
    
    # The script might exit because of kexec -e (mocked to echo)
    # We check if the overlay directory was prepared
    [ -d "/tmp/cafaye-overlay/etc/systemd/system/multi-user.target.wants" ]
    [ -f "/tmp/cafaye-overlay/etc/systemd/system/cafaye-install.service" ]
    grep -q "cafaye-installer.sh" "/tmp/cafaye-overlay/etc/systemd/system/cafaye-install.service"
    
    # Check if symlink exists in overlay
    [ -L "/tmp/cafaye-overlay/etc/systemd/system/multi-user.target.wants/cafaye-install.service" ]
}
