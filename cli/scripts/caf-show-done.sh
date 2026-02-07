#!/bin/bash

# Displays a completion indicator using gum
# Usage: caf-show-done "System update"

message="${1:-Task}"

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	"$message Complete! ☕"
