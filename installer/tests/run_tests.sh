#!/usr/bin/env bash
# Automated Test Suite for Cafaye Installer Wizard
# Minitest-style Reporter

set -e

REPO_DIR=$(pwd)
TEMP_STATE="/tmp/cafaye-test-state.json"
MOCK_GUM="/tmp/gum"
MOCK_JQ="/tmp/jq"

# --- Dependencies Setup (Quietly) ---
ensure_tool() {
    local name=$1
    local mock_path=$2
    if command -v "$name" &> /dev/null; then return 0; fi
    if [[ -f "$mock_path" ]]; then return 0; fi

    # Try System Package Manager (apt-get) for common tools
    if [[ "$name" == "jq" ]] && command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq jq > /dev/null
        return 0
    fi

    # Try Nix
    local nix_bin=$(nix build "nixpkgs#$name" --no-link --print-out-paths --extra-experimental-features "nix-command flakes" 2>/dev/null || echo "")
    
    # Try downloading standalone if possible (gum only)
    if [[ "$name" == "gum" ]]; then
        curl -fL "https://github.com/charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_Linux_x86_64.tar.gz" -o /tmp/gum.tar.gz
        tar xzf /tmp/gum.tar.gz -C /tmp
        find /tmp -name gum -type f -exec mv {} "$mock_path" \;
        chmod +x "$mock_path"
        return 0
    fi

# Setup Mocks
setup_mocks() {
    ensure_tool "gum" "$MOCK_GUM"
    ensure_tool "jq" "$MOCK_JQ"

    # Gum Wrapper
    mv "$MOCK_GUM" "$MOCK_GUM.real" 2>/dev/null || true
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
}

# --- Test Framework ---
FAILURES=()
TEST_COUNT=0

print_dot() { echo -n "."; }
print_fail() { echo -n "F"; }

report_failure() {
    local name=$1
    local detail=$2
    FAILURES+=("Failure:
$name
$detail")
}

run_test() {
    local name=$1
    local confirm=$2
    local choices=$3
    local import_keys=$4

    TEST_COUNT=$((TEST_COUNT + 1))
    
    # Setup Env
    export MOCK_CONFIRM="$confirm"
    export MOCK_CHOICES="$choices"
    export PATH="/tmp:$PATH"
    
    mkdir -p user
    cp user/user-state.json.example user/user-state.json 2>/dev/null || true
    
    # Execute
    local output
    if ! output=$(bash installer/cafaye-wizard.sh 2>&1); then
        # Script failed (exit code != 0)
        # Expected failure if confirm=no
        if [[ "$confirm" == "no" ]]; then
             print_dot
             return 0
        else
             print_fail
             report_failure "$name" "Wizard script exited with error. Output:\n$output"
             return 1
        fi
    else
        # Script success (exit code 0)
        if [[ "$confirm" == "no" ]]; then
            print_fail
            report_failure "$name" "Expected failure gave success"
            return 1
        fi
    fi

    # Verify State Content
    if [[ ! -f /tmp/cafaye-initial-state.json ]]; then
        print_fail
        report_failure "$name" "State file was not generated"
        return 1
    fi

    for choice in $choices; do
        local check=""
        case "$choice" in
            "🐳 Docker") check=".dev_tools.docker == true" ;;
            "🦀 Rust") check=".languages.rust == true" ;;
            "🛤️  Ruby on Rails") check=".frameworks.rails == true" ;;
        esac
        
        if [[ -n "$check" ]]; then
            # Using the real jq via ensure_tool or system
            if ! jq -e "$check" /tmp/cafaye-initial-state.json > /dev/null; then
               print_fail
               local content=$(cat /tmp/cafaye-initial-state.json)
               report_failure "$name" "Assertion failed: $check\nState Content:\n$content"
               return 1
            fi
        fi
    done

    print_dot
    rm -f /tmp/cafaye-initial-state.json
}

# --- Execution ---
setup_mocks

echo "# Running tests:"
echo ""

# Test Cases
run_test "Cancel Confirmation" "no" "" "false"
run_test "Select Docker and Rust" "yes" "🐳 Docker\n🦀 Rust" "false"
run_test "Select Rails and PostgreSQL" "yes" "Track\n🛤️  Ruby on Rails\n🐘 PostgreSQL" "true"

echo ""
echo ""
echo "Finished."
echo ""

if [ ${#FAILURES[@]} -eq 0 ]; then
    echo "$TEST_COUNT runs, $TEST_COUNT assertions, 0 failures, 0 errors"
    rm -f "$MOCK_GUM" "$MOCK_GUM.real" "$MOCK_JQ"
    exit 0
else
    echo "${#FAILURES[@]})"
    for fail in "${FAILURES[@]}"; do
        echo "$fail"
        echo ""
    done
    echo "$TEST_COUNT runs, ${#FAILURES[@]} failures"
    rm -f "$MOCK_GUM" "$MOCK_GUM.real" "$MOCK_JQ"
    exit 1
fi
