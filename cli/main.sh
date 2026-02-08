#!/bin/bash

# Main Cafaye OS CLI
# Usage: caf

export CLI_DIR="$(dirname "$(realpath "$0")")"
export PATH="$CLI_DIR/scripts:$PATH"

show_main_menu() {
    clear
    caf-logo-show
    echo ""
    
    choice=$(gum choose --header "Main Menu" \
        "📦 Install (Languages & Frameworks)" \
        "⚙️  Services (Postgres, Redis)" \
        "🎨 Style (Themes & UI)" \
        "🏥 Status (System Health)" \
        "🔄 Update & Rebuild" \
        "  About" \
        "👋 Exit")

    case "$choice" in
        *"Install"*) show_install_menu ;;
        *"Services"*) show_services_menu ;;
        *"Style"*) show_style_menu ;;
        *"Status"*) show_status_menu ;;
        *"Update"*) run_system_update ;;
        *"About"*) show_about ;;
        *"Exit"*) exit 0 ;;
    esac
}

show_install_menu() {
    choice=$(gum choose --header "Install Submenu" \
        "🛤️  Ruby on Rails" \
        "🐎 Django" \
        "⚛️  Next.js" \
        "🦀 Rust" \
        "Hamster Go" \
        "🟢 Node.js" \
        "🐍 Python" \
        "💎 Ruby" \
        "🐳 Docker" \
        "🗄️  Docker DBs" \
        "⬅️  Back")

    case "$choice" in
        *"Rails"*) toggle_framework "rails" "Ruby & PostgreSQL" ;;
        *"Django"*) toggle_framework "django" "Python & PostgreSQL" ;;
        *"Next.js"*) toggle_framework "nextjs" "Node.js" ;;
        "🦀 Rust") toggle_language "rust" ;;
        "Hamster Go") toggle_language "go" ;;
        "🟢 Node.js") toggle_language "nodejs" ;;
        "🐍 Python") toggle_language "python" ;;
        "💎 Ruby") toggle_language "ruby" ;;
        "🐳 Docker") toggle_service "docker" ;;
        *"Docker DBs"*) caf-docker-db-install ;;
        "⬅️  Back") show_main_menu ;;
    esac
}

show_services_menu() {
    choice=$(gum choose --header "Backend Services" \
        "🐘 PostgreSQL" \
        "🧠 Redis" \
        "⬅️  Back")

    case "$choice" in
        *"PostgreSQL"*) toggle_backend_service "postgresql" ;;
        *"Redis"*) toggle_backend_service "redis" ;;
        "⬅️  Back") show_main_menu ;;
    esac
}

toggle_backend_service() {
    service=$1
    current=$(caf-state-read "services.$service")
    
    if [[ "$current" == "true" ]]; then
        gum confirm "Disable $service (System Service)?" && caf-state-write "services.$service" "false"
    else
        gum confirm "Enable $service (System Service)?" && caf-state-write "services.$service" "true"
    fi
    
    if gum confirm "Apply changes now? (Rebuild)"; then
        caf-system-rebuild
    fi
    show_services_menu
}

run_system_update() {
    gum confirm "Perform a full system update and rebuild?" || return
    
    # Run pre-update hook if any
    caf-hook-run pre-update
    
    # Execute rebuild
    caf-system-rebuild
    
    # Run post-update hook
    caf-hook-run post-update
    
    caf-task-done "System Update"
    read -p "Press enter to return..."
    show_main_menu
}

show_status_menu() {
    clear
    echo "🏥 Cafaye System Health"
    echo "------------------------"
    
    # Check Tailscale
    if caf-cmd-present tailscale; then
        ts_status=$(tailscale status --short 2>/dev/null || echo "Not connected")
        echo "🌐 Tailscale: $ts_status"
    fi
    
    # Check ZRAM
    if caf-cmd-present zramctl; then
        zram_status=$(zramctl --noheadings | wc -l)
        if [[ $zram_status -gt 0 ]]; then
            echo "🧠 ZRAM: Enabled"
        else
            echo "🧠 ZRAM: Disabled"
        fi
    fi
    
    # Check Docker
    if caf-cmd-present docker; then
        if systemctl is-active --quiet docker; then
            echo "🐳 Docker: Active"
        else
            echo "🐳 Docker: Inactive"
        fi
    fi

    # Check NixOS generation
    gen=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
    echo "📌 Current Generation: $gen"
    
    echo "------------------------"
    read -p "Press enter to return..."
    show_main_menu
}

show_style_menu() {
    choice=$(gum choose --header "Style Submenu" \
        "🌙 Catppuccin Mocha" \
        "☀️  Light Mode (Coming Soon)" \
        "⬅️  Back")

    case "$choice" in
        *"Mocha"*) 
            caf-state-write "interface.theme" "catppuccin-mocha"
            caf-hook-run theme-set
            echo "Theme set to Catppuccin Mocha!"
            sleep 1
            ;;
        "⬅️  Back") show_main_menu ;;
    esac
    show_style_menu
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

toggle_framework() {
    framework=$1
    deps=$2
    current=$(caf-state-read "frameworks.$framework")
    
    if [[ "$current" == "true" ]]; then
        gum confirm "Uninstall $framework stack?" && caf-state-write "frameworks.$framework" "false"
    else
        echo "💡 Note: Installing $framework will also enable: $deps"
        gum confirm "Install $framework stack?" && caf-state-write "frameworks.$framework" "true"
    fi
    
    if gum confirm "Apply changes now? (Rebuild)"; then
        caf-system-rebuild
    fi
    show_install_menu
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
