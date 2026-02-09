#!/usr/bin/env bash
# Layer 0: Installer Wizard Tests
# This verifies the logic of the TUI wizard without running it.

source tests/lib/caftest.sh

describe "Layer 0: Installer Logic"

# Setup Mocks
MOCK_GUM="/tmp/gum"
MOCK_JQ="/tmp/jq"
STATE_FILE="/tmp/cafaye-installer-test-state.json"

setup() {
    # Provide Mock Gum
    cat > "$MOCK_GUM" << 'EOF'
#!/usr/bin/env bash
cmd=$1
shift
case "$cmd" in
    confirm) if [[ "$MOCK_CONFIRM" == "no" ]]; then exit 1; else exit 0; fi ;;
    choose) echo -e "$MOCK_CHOICES" ;;
    *) echo "Gum called with unknown command: $cmd" >&2; exit 1 ;;
esac
EOF
    chmod +x "$MOCK_GUM"
    export PATH="/tmp:$PATH"
    
    # Ensure JQ (System or Nix)
    if ! command -v jq &> /dev/null; then
        # Check if we have nix
        if ! command -v nix &> /dev/null; then
            echo "Error: JQ and Nix not found. Cannot run test."
            exit 1
        fi
        # Build JQ
        local jq_bin=$(nix build nixpkgs#jq --no-link --print-out-paths 2>/dev/null)/bin/jq
        ln -sf "$jq_bin" "$MOCK_JQ"
    fi
}

teardown() {
    rm -f "$MOCK_GUM" "$MOCK_JQ" "$STATE_FILE"
}

it "generates correct state for Rust + Docker"
    export MOCK_CONFIRM="yes"
    export MOCK_CHOICES="🐳 Docker\n🦀 Rust"
    
    # Run Wizard (Redirect output)
    bash installer/cafaye-wizard.sh > /dev/null 2>&1
    
    # Verify
    assert_file_exists "/tmp/cafaye-initial-state.json"
    assert_json_path "/tmp/cafaye-initial-state.json" ".dev_tools.docker" "true"
    assert_json_path "/tmp/cafaye-initial-state.json" ".languages.rust" "true"
    assert_json_path "/tmp/cafaye-initial-state.json" ".frameworks.rails" "false"

it "fails gracefully on user cancel"
    export MOCK_CONFIRM="no"
    if bash installer/cafaye-wizard.sh > /dev/null 2>&1; then
        echo "Wizard should have exited with error code"
        exit 1
    fi

run_suite
