#!/bin/bash
set -euo pipefail

# Cafaye Uninstaller
# Usage: ./uninstall.sh [--yes]

AUTO_YES=false
if [[ "${1:-}" == "--yes" ]] || [[ "${1:-}" == "-y" ]]; then
    AUTO_YES=true
fi

echo "⚠️  Cafaye OS Uninstaller"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will remove:"
echo "  • ~/.config/cafaye (all configuration)"
echo "  • Nix packages installed by Cafaye"
echo "  • Home Manager generations"
echo ""
echo "This will NOT remove:"
echo "  • Nix itself (use 'nix-uninstall' separately if needed)"
echo "  • Your Git repositories"
echo "  • User data outside ~/.config/cafaye"
echo ""

if [[ "$AUTO_YES" != "true" ]]; then
    read -p "Continue with uninstall? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi
fi

echo "🗑️  Removing Cafaye..."

# 1. Backup current state
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [[ -d "$HOME/.config/cafaye" ]]; then
    echo "📦 Creating backup at ~/.config/cafaye.uninstall-backup.$TIMESTAMP"
    cp -r "$HOME/.config/cafaye" "$HOME/.config/cafaye.uninstall-backup.$TIMESTAMP"
fi

# 2. Remove Home Manager generations
if command -v home-manager &> /dev/null; then
    echo "🧹 Removing Home Manager generations..."
    home-manager expire-generations "-0 days" 2>/dev/null || true
fi

# 3. Remove configuration directory
if [[ -d "$HOME/.config/cafaye" ]]; then
    echo "🗑️  Removing ~/.config/cafaye..."
    rm -rf "$HOME/.config/cafaye"
fi

# 4. Remove symlinks that might have been created
echo "🔗 Removing symlinks..."
for link in ".zshrc" ".zshenv" ".config/tmux" ".config/ghostty"; do
    if [[ -L "$HOME/$link" ]]; then
        target=$(readlink "$HOME/$link")
        if [[ "$target" == *"cafaye"* ]]; then
            echo "   Removing $HOME/$link"
            rm "$HOME/$link"
        fi
    fi
done

# 5. Restore backups if they exist
for backup in "$HOME/.zshrc.backup"* "$HOME/.zshenv.backup"*; do
    if [[ -f "$backup" ]]; then
        original="${backup%.backup*}"
        if [[ ! -e "$original" ]]; then
            echo "📥 Restoring $backup to $original"
            mv "$backup" "$original"
            break
        fi
    fi
done

echo ""
echo "✅ Cafaye has been uninstalled."
echo ""
echo "📁 Backup saved to: ~/.config/cafaye.uninstall-backup.$TIMESTAMP"
echo ""
echo "To completely remove Nix:"
echo "  sudo /nix/nix-installer uninstall"
echo ""
