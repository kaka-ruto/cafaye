#!/bin/bash

# Displays the Cafaye ASCII logo
# Usage: caf-show-logo

LOGO_FILE="/etc/cafaye/branding/logo.txt"

if [[ ! -f "$LOGO_FILE" ]]; then
    LOGO_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/config/cafaye/branding/logo.txt"
fi

if [[ -f "$LOGO_FILE" ]]; then
    cat "$LOGO_FILE"
else
    echo "☕ Cafaye OS"
fi
