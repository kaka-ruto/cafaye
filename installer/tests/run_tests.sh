#!/usr/bin/env bash
# Automated Test Suite for Cafaye Installer Wizard

set -e

REPO_DIR=$(pwd)
TEMP_STATE="/tmp/cafaye-test-state.json"
MOCK_GUM="/tmp/gum"

echo "🧪 Starting Installer Automated Tests..."

# Ensure jq is present for state verification
if ! command -v jq &> /dev/null; then
    if command -v nix &> /dev/null; then
        echo "Auto-installing jq for tests..."
        export PATH="$(nix build nixpkgs#jq --no-link --print-out-paths --extra-experimental-features "nix-command flakes")/bin:$PATH"
    fi
fi
cat > "$MOCK_GUM" << 'EOF'
#!/usr/bin/env bash
cmd=$1
shift
case "$cmd" in
    confirm)
        # Always confirm yes unless mock env says no
        if [[ "$MOCK_CONFIRM" == "no" ]]; then exit 1; else exit 0; fi
        ;;
    choose)
        # Return mock choices
        echo -e "$MOCK_CHOICES"
        ;;
    *)
        exit 0
        ;;
esac
EOF
chmod +x "$MOCK_GUM"

# Function to run the wizard with mocks
run_wizard_test() {
    local name=$1
    local confirm=$2
    local choices=$3
    local import_keys=$4
    
    echo -n "Test: $name... "
    
    # Setup environment
    export MOCK_CONFIRM="$confirm"
    export MOCK_CHOICES="$choices"
    export PATH="/tmp:$PATH" # Use mock gum
    
    # Mock files
    mkdir -p user
    cp user/user-state.json.example user/user-state.json
    
    # Run wizard
    if [[ "$confirm" == "no" ]]; then
        if bash installer/cafaye-wizard.sh; then
            echo "❌ FAILED (Should have exited with error on cancel)"
            exit 1
        else
            echo "✅ PASSED (Cancelled correctly)"
            return 0
        fi
    fi

    bash installer/cafaye-wizard.sh
    
    # Verify State
    if [[ ! -f /tmp/cafaye-initial-state.json ]]; then
        echo "❌ FAILED (State file not generated)"
        exit 1
    fi
    
    # Check specific selections
    for choice in $choices; do
        local check=""
        case "$choice" in
            "🐳 Docker") check=".dev_tools.docker == true" ;;
            "🦀 Rust") check=".languages.rust == true" ;;
            "🛤️  Ruby on Rails") check=".frameworks.rails == true" ;;
        esac
        
        if [[ -n "$check" ]]; then
            if ! jq -e "$check" /tmp/cafaye-initial-state.json > /dev/null; then
                echo "❌ FAILED (Choice $choice not reflected in state)"
                echo "Current State Content:"
                cat /tmp/cafaye-initial-state.json
                exit 1
            fi
        fi
    done
    
    echo "✅ PASSED"
    rm -f /tmp/cafaye-initial-state.json
}

# --- Test Cases ---

# 1. User Cancels immediately
run_wizard_test "Cancel Confirmation" "no" "" "false"

# 2. Basic Success with Docker and Rust
run_wizard_test "Select Docker and Rust" "yes" "🐳 Docker\n🦀 Rust" "false"

# 3. Full Stack selection
run_wizard_test "Select Rails and PostgreSQL" "yes" "Track\n🛤️  Ruby on Rails\n🐘 PostgreSQL" "true"

echo "---------------------------------------"
echo "🎉 ALL TESTS PASSED SUCCESSFULLY!"
echo "---------------------------------------"

rm "$MOCK_GUM"
