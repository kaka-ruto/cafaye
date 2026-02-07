#!/bin/bash

# Reads a value from user/user-state.json
# Usage: caf-state-read "languages.ruby"

STATE_FILE="/etc/cafaye/user/user-state.json"

# In dev/test environments, fallback to local path if /etc doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    STATE_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/user/user-state.json"
fi

key="$1"
jq -r ".$key" "$STATE_FILE"
