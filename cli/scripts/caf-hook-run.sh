#!/bin/bash

# Runs user hooks if they exist
# Usage: caf-hook-run post-update

hook_name="$1"
USER_HOOKS_DIR="$HOME/.config/cafaye/hooks"
SYSTEM_HOOKS_DIR="/etc/cafaye/hooks"

run_hook() {
    local hook_path="$1"
    if [[ -x "$hook_path" ]]; then
        echo "🪝 Running hook: $hook_name ($hook_path)"
        "$hook_path"
    fi
}

# Run system hooks first
run_hook "$SYSTEM_HOOKS_DIR/$hook_name"

# Run user hooks second
run_hook "$USER_HOOKS_DIR/$hook_name"
