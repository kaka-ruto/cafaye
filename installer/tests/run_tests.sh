#!/usr/bin/env bash
# Automated Test Suite for Cafaye Installer Wizard

set -e

REPO_DIR=$(pwd)
TEMP_STATE="/tmp/cafaye-test-state.json"
MOCK_GUM="/tmp/gum"
MOCK_JQ="/tmp/jq"

echo "🧪 Starting Installer Automated Tests..."

# --- Helper: Ensure dependencies ---
ensure_tool() {
    local name=$1
    local mock_path=$2
    if command -v "$name" &> /dev/null; then
        return 0
    fi
    
    if [[ -f "$mock_path" ]]; then
        return 0
    fi

    echo "Missing $name. Attempting to provide it..."
    
    # Try Nix first
    local nix_bin=$(nix build "nixpkgs#$name" --no-link --print-out-paths --extra-experimental-features "nix-command flakes" 2>/dev/null || echo "")
    if [[ -n "$nix_bin" ]]; then
        ln -sf "$nix_bin/bin/$name" "$mock_path"
        return 0
    fi

    # Try downloading standalone if possible (gum only)
    if [[ "$name" == "gum" ]]; then
        curl -fL "https://github.com/charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_Linux_x86_64.tar.gz" -o /tmp/gum.tar.gz
        tar xzf /tmp/gum.tar.gz -C /tmp
        find /tmp -name gum -type f -exec mv {} /tmp/gum \;
        chmod +x /tmp/gum
        return 0
    fi

    echo "Error: Could not provide $name"
    exit 1
}

ensure_tool "gum" "$MOCK_GUM"
ensure_tool "jq" "$MOCK_JQ"

# --- Redefine Gum for MOCKING logic ---
# We keep the real gum as /tmp/gum.real and make /tmp/gum a wrapper
mv "$MOCK_GUM" "$MOCK_GUM.real"
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
        /tmp/gum.real "$cmd" "$@"
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
    export PATH="/tmp:$PATH"
    
    # Mock files
    mkdir -p user
    cp user/user-state.json.example user/user-state.json 2>/dev/null || true
    
    # Run wizard
    if [[ "$confirm" == "no" ]]; then
        if bash installer/cafaye-wizard.sh > /dev/null 2>&1; then
            echo "❌ FAILED (Should have exited with error on cancel)"
            exit 1
        else
            echo "✅ PASSED (Cancelled correctly)"
            return 0
        fi
    fi

    bash installer/cafaye-wizard.sh > /dev/null 2>&1 || { echo "❌ FAILED (Wizard crashed)"; exit 1; }
    
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
            if jq -e "$check" /tmp/cafaye-initial-state.json > /dev/null; then
               :
            else
                echo "❌ FAILED (Choice $choice not reflected in state)"
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

rm -f "$MOCK_GUM" "$MOCK_GUM.real" "$MOCK_JQ"
