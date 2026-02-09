export BATS_LIB_PATH="${BATS_LIB_PATH:-/usr/lib/bats}"

# Loads standard BATS helpers if available (not strictly enforced for now)
setup() {
    export REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    cd "$REPO_DIR" || exit 1
}
