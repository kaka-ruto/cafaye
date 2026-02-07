#!/bin/bash

# Writes a value to user/user-state.json
# Usage: caf-state-write "languages.ruby" "true"

STATE_FILE="/Users/kaka/Code/Cafaye/cafaye/user/user-state.json"

key="$1"
value="$2"

# Simple type detection for boolean/numbers
if [[ "$value" == "true" || "$value" == "false" || "$value" =~ ^[0-9]+$ ]]; then
    tmp=$(mktemp)
    jq ".$key = $value" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
else
    # Treat as string
    tmp=$(mktemp)
    jq ".$key = \"$value\"" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
fi
