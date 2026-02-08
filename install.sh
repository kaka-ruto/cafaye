#!/bin/bash
# Cafaye OS: One-Line VPS Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
#   OR
#   ./install.sh (from within the repo)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect if running from pipe (curl|bash or source <(...))
is_pipe_mode() {
  [[ -z "${BASH_SOURCE[0]}" ]]
}

# Get directory where this script is located
get_script_dir() {
  if is_pipe_mode; then
    pwd
  else
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
  fi
}

main() {
  local script_dir
  script_dir=$(get_script_dir)
  
  # Check if we're in the right place
  if [[ -f "$script_dir/installer/main.sh" ]]; then
    # We're in the right directory, run the installer
    source "$script_dir/installer/main.sh" "$script_dir"
    return
  fi
  
  # We need to clone first (pipe mode)
  echo -e "${BLUE}Downloading Cafaye OS...${NC}"
  
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  git clone --depth 1 https://github.com/kaka-ruto/cafaye
  cd cafaye
  
  echo -e "${GREEN}✓ Downloaded Cafaye to $temp_dir/cafaye${NC}"
  echo ""
  
  # Now run the installer from the cloned directory
  source "$temp_dir/cafaye/installer/main.sh" "$temp_dir/cafaye"
}

main "$@"
