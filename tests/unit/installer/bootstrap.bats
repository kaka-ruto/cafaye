#!/usr/bin/env bats

setup() {
    export REPO_DIR="/tmp/cafaye-repo"
    export FAKE_HOME="/tmp/cafaye-home"
    # Clean up previous runs robustly
    [ -d "$REPO_DIR" ] && find "$REPO_DIR" -type l -delete || true
    rm -rf "$REPO_DIR" "$FAKE_HOME" || true
    mkdir -p "$REPO_DIR" "$FAKE_HOME"
    # Sync current repo to temp repo, excluding large/problematic dirs
    rsync -a --exclude=".git" --exclude=".devbox" --exclude="result" . "$REPO_DIR/"
}

teardown() {
    [ -d "$REPO_DIR" ] && find "$REPO_DIR" -type l -delete || true
    rm -rf "$REPO_DIR" "$FAKE_HOME" || true
}

@test "install.sh generates state files in non-interactive mode" {
    cd "$REPO_DIR"
    
    # Mock HOME to redirect config generation
    export HOME="$FAKE_HOME"
    
    # Mock dependencies to avoid actual network/system installs
    mkdir -p "$FAKE_HOME/bin"
    cat > "$FAKE_HOME/bin/curl" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "$FAKE_HOME/bin/git" <<EOF
#!/bin/bash
[[ "\$1" == "init" ]] && exit 0
exit 0
EOF
    cat > "$FAKE_HOME/bin/sudo" <<EOF
#!/bin/bash
"\$@"
EOF
    cat > "$FAKE_HOME/bin/gum" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "$FAKE_HOME/bin/nix" <<EOF
#!/bin/bash
exit 0
EOF
    cat > "$FAKE_HOME/bin/home-manager" <<EOF
#!/bin/bash
exit 0
EOF
    chmod +x "$FAKE_HOME/bin/"*
    export PATH="$FAKE_HOME/bin:$PATH"

    # Run with --yes. It might fail later on Nix install, but state should be written.
    ./install.sh --yes || true
    
    [ -d "$FAKE_HOME/.config/cafaye" ]
    [ -f "$FAKE_HOME/.config/cafaye/environment.json" ]
    [ -f "$FAKE_HOME/.config/cafaye/settings.json" ]
}

@test "install.sh skips wizard in non-interactive mode" {
    cd "$REPO_DIR"
    export HOME="$FAKE_HOME"
    
    # We use a timeout to verify it completes or fails quickly without hanging on interactive gum/read
    run timeout 5s ./install.sh --yes
    [ "$status" -ne 124 ] # 124 is timeout
}
