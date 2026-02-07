#!/bin/bash

# Checks if a command exists in PATH
# Usage: caf-cmd-present git

if command -v "$1" &>/dev/null; then
    exit 0
else
    exit 1
fi
