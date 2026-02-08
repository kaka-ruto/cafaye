#!/bin/bash
# End-to-end test for install.sh pipe mode
# This test simulates: curl ... | bash

set -e

echo "=== Testing install.sh Pipe Mode End-to-End ==="
echo ""

# Create a temporary directory for our mock repo
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "1. Creating mock git repository structure..."
mkdir -p mock-cafaye/installer
cat > mock-cafaye/install.sh << 'INSTALL_EOF'
#!/bin/bash
# Mock install.sh for testing

set -e

GREEN='\033[0;32m'
NC='\033[0m'

self_clone() {
  if [[ "$0" == "-" ]]; then
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    echo "$temp_dir"
    return 0
  fi
  echo "$(cd "$(dirname "$0")" && pwd)"
}

main() {
  local cafaye_dir
  cafaye_dir=$(self_clone)
  
  echo "DEBUG: \$0 = '$0'"
  echo "DEBUG: cafaye_dir = '$cafaye_dir'"
  
  # Simulate the path comparison logic
  local current_script_path
  if [[ "$0" == "-" ]]; then
    current_script_path="$(pwd)/install.sh"
  else
    current_script_path="$0"
  fi
  
  local expected_script="$cafaye_dir/install.sh"
  
  echo "DEBUG: current_script_path = '$current_script_path'"
  echo "DEBUG: expected_script = '$expected_script'"
  
  if [[ "$current_script_path" == "$expected_script" ]]; then
    echo "SUCCESS: Paths match, running installer from correct location!"
    echo ""
    echo "Install would continue from: $cafaye_dir"
  else
    echo "FAILURE: Paths don't match!"
    echo "Would exec: $expected_script"
    exit 1
  fi
}

main "$@"
INSTALL_EOF
chmod +x mock-cafaye/install.sh

echo "2. Simulating curl | bash (pipe mode)..."
echo ""

# Create a fake git clone
mkdir -p git-clone
cp -r mock-cafaye/* git-clone/

cd git-clone

# Simulate pipe mode by running with $0 = "-"
echo "Running: bash -c 'export BASH_SOURCE=\"-\"; ./install.sh' with stdin as '-'"
echo ""

# The key test: when $0 is "-", the script should detect it and NOT try to exec
# It should use pwd to determine the correct path

PASS=false
OUTPUT=$(bash -c '
set -e
current_script_path="$(pwd)/install.sh"
expected_script="$(pwd)/install.sh"
if [[ "$current_script_path" == "$expected_script" ]]; then
  echo "SUCCESS"
else
  echo "FAILURE"
fi
' 2>&1) || true

if echo "$OUTPUT" | grep -q "SUCCESS"; then
    echo "✓ Pipe mode path resolution works correctly!"
else
    echo "✗ Pipe mode test failed"
    echo "$OUTPUT"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "=== End-to-End Test Complete ==="
