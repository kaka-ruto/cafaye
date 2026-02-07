#!/bin/bash

# Main Cafaye OS CLI
# Usage: caf

export CLI_DIR="$(dirname "$(realpath "$0")")"
export PATH="$CLI_DIR/scripts:$PATH"

show_main_menu() {
    clear
    cat /etc/cafaye/branding/logo.txt 2>/dev/null || echo "☕ Cafaye OS"
    echo ""
    
    choice=$(gum choose --header "Main Menu" \
        "📦 Install (Languages & Services)" \
        "🎨 Style (Themes & UI)" \
        "⚙️  Setup (System Config)" \
        "🚀 Rebuild System" \
        "  About" \
        "👋 Exit")

    case "$choice" in
        *"Install"*) show_install_menu ;;
        *"Style"*) show_style_menu ;;
        *"Setup"*) show_setup_menu ;;
        *"Rebuild"*) caf-system-rebuild ;;
        *"About"*) show_about ;;
        *"Exit"*) exit 0 ;;
    esac
}

show_install_menu() {
    choice=$(gum choose --header "Install Submenu" \
        "🦀 Rust" \
        "🐹 Go" \
        "🟢 Node.js" \
        "🐍 Python" \
        "💎 Ruby" \
        "🐳 Docker" \
        "⬅️  Back")

    case "$choice" in
        "🦀 Rust") toggle_language "rust" ;;
        "🐹 Go") toggle_language "go" ;;
        "🟢 Node.js") toggle_language "nodejs" ;;
        "🐍 Python") toggle_language "python" ;;
        "💎 Ruby") toggle_language "ruby" ;;
        "🐳 Docker") toggle_service "docker" ;;
        "⬅️  Back") show_main_menu ;;
    esac
}

toggle_language() {
    lang=$1
    current=$(caf-state-read "languages.$lang")
    
    if [[ "$current" == "true" ]]; then
        gum confirm "Uninstall $lang?" && caf-state-write "languages.$lang" "false"
    else
        gum confirm "Install $lang?" && caf-state-write "languages.$lang" "true"
    fi
    
    if gum confirm "Apply changes now? (Rebuild)"; then
        caf-system-rebuild
    fi
    show_install_menu
}

toggle_service() {
    service=$1
    current=$(caf-state-read "dev_tools.$service")
    
    if [[ "$current" == "true" ]]; then
        gum confirm "Disable $service?" && caf-state-write "dev_tools.$service" "false"
    else
        gum confirm "Enable $service?" && caf-state-write "dev_tools.$service" "true"
    fi
    
    if gum confirm "Apply changes now? (Rebuild)"; then
        caf-system-rebuild
    fi
    show_install_menu
}

show_style_menu() {
    echo "Stying coming soon..."
    sleep 1
    show_main_menu
}

show_setup_menu() {
    echo "Setup coming soon..."
    sleep 1
    show_main_menu
}

show_about() {
    fastfetch --config /etc/cafaye/fastfetch/config.jsonc
    read -p "Press enter to return..."
    show_main_menu
}

# Start
if [[ -n "$1" ]]; then
    # Handle direct commands if any
    echo "Direct commands not yet implemented"
else
    show_main_menu
fi
