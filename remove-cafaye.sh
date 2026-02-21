#!/bin/bash
# Cafaye Removal Script
# Run this to completely remove Cafaye from your system

set -e

echo "=== Cafaye Removal Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to safely remove symlinks
remove_symlink() {
    local target="$1"
    if [ -L "$target" ]; then
        if readlink "$target" | grep -q "cafaye\|nix/store"; then
            echo -e "${YELLOW}Removing symlink:${NC} $target -> $(readlink "$target")"
            rm "$target"
        fi
    fi
}

# Function to backup and remove
backup_and_remove() {
    local target="$1"
    if [ -e "$target" ]; then
        local backup="${target}.pre-cafaye-$(date +%Y%m%d)"
        echo -e "${YELLOW}Backing up and removing:${NC} $target"
        mv "$target" "$backup"
        echo "  Backup created: $backup"
    fi
}

echo -e "${GREEN}Step 1: Removing Cafaye symlinks from ~/.config/${NC}"
echo "─────────────────────────────────────────"

# Remove symlinks pointing to cafaye configs
remove_symlink "$HOME/.config/lazygit"
remove_symlink "$HOME/.config/starship.toml"

# Remove nvim cafaye config symlinks
if [ -L "$HOME/.config/nvim/lua/config/cafaye-defaults.lua" ]; then
    remove_symlink "$HOME/.config/nvim/lua/config/cafaye-defaults.lua"
fi

echo ""
echo -e "${GREEN}Step 2: Removing Cafaye directories${NC}"
echo "─────────────────────────────────────────"

# Remove cafaye config directories
backup_and_remove "$HOME/.config/cafaye"
backup_and_remove "$HOME/.config/cafaye.bak.manual"

echo ""
echo -e "${GREEN}Step 3: Restoring shell configuration${NC}"
echo "─────────────────────────────────────────"

# Remove nix-managed zshrc symlink and create minimal one
if [ -L "$HOME/.zshrc" ]; then
    if readlink "$HOME/.zshrc" | grep -q "nix/store"; then
        echo -e "${YELLOW}Removing Nix-managed .zshrc symlink${NC}"
        rm "$HOME/.zshrc"
        
        # Create minimal zshrc
        cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Minimal .zshrc - restored after Cafaye removal
# Add your custom configuration here

# Basic settings
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Options
setopt AUTO_CD EXTENDED_GLOB NO_BEEP

# Useful aliases
alias ls='ls -G'
alias ll='ls -la'
alias ..='cd ..'

# Load completions
autoload -Uz compinit && compinit

echo "Shell restored. Customize ~/.zshrc as needed."
ZSHRC_EOF
        echo -e "${GREEN}Created minimal ~/.zshrc${NC}"
    fi
fi

# Clean up zshrc backup symlink
if [ -L "$HOME/.zshrc.backup" ]; then
    echo -e "${YELLOW}Removing .zshrc.backup symlink${NC}"
    rm "$HOME/.zshrc.backup"
fi

echo ""
echo -e "${GREEN}Step 4: Cleaning up PATH and environment${NC}"
echo "─────────────────────────────────────────"

# Remove cafaye from PATH in .zprofile if present
if [ -f "$HOME/.zprofile" ]; then
    if grep -q "cafaye" "$HOME/.zprofile"; then
        echo -e "${YELLOW}Backing up .zprofile with cafaye references${NC}"
        cp "$HOME/.zprofile" "$HOME/.zprofile.pre-cafaye-$(date +%Y%m%d)"
        # Remove cafaye PATH entries
        sed -i.bak '/cafaye/d' "$HOME/.zprofile"
        rm -f "$HOME/.zprofile.bak"
        echo -e "${GREEN}Cleaned .zprofile${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Step 5: Optional - Nix removal${NC}"
echo "─────────────────────────────────────────"
echo "Nix is still installed at: $(which nix)"
echo ""
echo "To completely remove Nix, run:"
echo "  sudo rm -rf /nix"
echo "  sudo rm -rf ~/.nix-*"
echo "  sudo rm -rf /etc/nix"
echo ""
echo "Or use the official Nix uninstaller:"
echo "  /nix/nix-installer uninstall"
echo ""

echo ""
echo -e "${GREEN}=== Cafaye Removal Complete ===${NC}"
echo ""
echo "Summary of changes:"
echo "  ✓ Removed Cafaye config symlinks"
echo "  ✓ Removed Cafaye directories (backed up)"
echo "  ✓ Restored minimal shell configuration"
echo "  ✓ Cleaned PATH references"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Please restart your terminal or run:"
echo "  source ~/.zshrc"
echo ""
echo "Your original configs were backed up with .pre-cafaye- suffix"
echo ""
