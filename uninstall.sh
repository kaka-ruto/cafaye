#!/bin/bash
set -euo pipefail

# Cafaye Uninstaller
# Usage: ./uninstall.sh [--yes]

AUTO_YES=false
if [[ "${1:-}" == "--yes" ]] || [[ "${1:-}" == "-y" ]]; then
    AUTO_YES=true
fi

echo "⚠️  Cafaye System Reset & Clean-Up"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This procedure will revert your environment to its pre-Cafaye state:"
echo "  • Removes ~/.config/cafaye (all configuration settings)"
echo "  • Cleans up Nix packages installed by the Cafaye runtime"
echo "  • Manages Home Manager generation expiration"
echo ""
echo "System safety check:"
echo "  • Your personal Git repositories will NOT be affected"
echo "  • Global Nix installation will remain intact"
echo "  • A safety backup will be created before any files are deleted"
echo ""

if [[ "$AUTO_YES" != "true" ]]; then
    read -p "Proceed with system reset? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Reset cancelled."
        exit 0
    fi
fi

echo "🧹 Initializing cleanup sequence..."

# 1. Backup current state
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [[ -d "$HOME/.config/cafaye" ]]; then
    echo "📦 Creating safety snapshot at ~/.config/cafaye.uninstall-backup.$TIMESTAMP"
    cp -r "$HOME/.config/cafaye" "$HOME/.config/cafaye.uninstall-backup.$TIMESTAMP"
fi

# 2. Remove Home Manager generations
if command -v home-manager &> /dev/null; then
    echo "❄️  Expiring Home Manager generations..."
    home-manager expire-generations "-0 days" 2>/dev/null || true
fi

# 3. Remove configuration directory
if [[ -d "$HOME/.config/cafaye" ]]; then
    echo "🗑️  Removing configuration directory..."
    rm -rf "$HOME/.config/cafaye"
fi

# 4. Remove symlinks that might have been created
echo "🔗 Cleaning up system symlinks..."
for link in ".zshrc" ".zshenv" ".config/tmux" ".config/ghostty"; do
    if [[ -L "$HOME/$link" ]]; then
        target=$(readlink "$HOME/$link")
        if [[ "$target" == *"cafaye"* ]]; then
            echo "   Removing $HOME/$link"
            rm "$HOME/$link"
        fi
    fi
done

# 4b. Remove Bash auto-shell transition
if [[ -f "$HOME/.bashrc" ]]; then
    echo "🐚 Removing shell transition guard from .bashrc..."
    # Create temp file without the cafaye block
    sed '/# --- Cafaye Auto-Shell ---/,/fi/d' "$HOME/.bashrc" > "$HOME/.bashrc.tmp" && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
fi

# 5. Restore backups if they exist
echo "📥 Restoring previous configuration backups..."
for file in ".zshrc" ".zshenv"; do
    # Find the most recent backup
    latest_backup=$(ls -t "$HOME/${file}.backup"* 2>/dev/null | head -n 1 || true)
    if [[ -n "$latest_backup" && -f "$latest_backup" ]]; then
        if [[ ! -e "$HOME/$file" ]]; then
            echo "   Restoring $latest_backup -> $HOME/$file"
            mv "$latest_backup" "$HOME/$file"
        fi
    fi
done

echo ""
echo "✅ System reset complete."
echo ""
echo "📁 Safety snapshot: ~/.config/cafaye.uninstall-backup.$TIMESTAMP"
echo ""
echo "Note: To completely remove the Nix package manager, run:"
echo "  sudo /nix/nix-installer uninstall"
echo ""
