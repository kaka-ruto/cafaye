#!/bin/bash
# Cafaye OS: Installer Wizard (TUI)
# Collects all user preferences before starting the background installation.

set -e

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure gum is available (should be installed by bootstrap)
if ! command -v gum &> /dev/null; then
    echo "Error: gum not found. Please run this via install.sh"
    exit 1
fi

cat << "EOF"
  ☕ Cafaye OS: The cloud-native powerhouse
  -----------------------------------------
EOF

# 1. Hardware Detection & Confirmation
disk=$(lsblk -dn -o NAME,TYPE | grep "disk" | head -n1 | awk '{print "/dev/"$1}')
mem=$(free -h | awk '/^Mem:/ {print $2}')

echo -e "🔍 ${CYAN}Hardware Detected:${NC}"
echo "   Disk: $disk"
echo "   RAM:  $mem"
echo ""

if ! gum confirm "Install Cafaye OS on $disk? (THIS WILL ERASE ALL DATA)"; then
    echo "Installation cancelled."
    exit 0
fi

# 2. SSH Configuration
echo -e "🔑 ${CYAN}Security:${NC}"
if [[ -f /root/.ssh/authorized_keys ]]; then
    key_count=$(wc -l < /root/.ssh/authorized_keys)
    if gum confirm "I found $key_count existing SSH keys. Import them into the new OS?"; then
        import_keys=true
    else
        import_keys=false
    fi
else
    echo "⚠️  No SSH keys found in /root/.ssh/authorized_keys"
    import_keys=false
fi

# 3. Features & Modules
echo -e "🛠️  ${CYAN}Default Stack:${NC}"
choice=$(gum choose --no-limit --cursor "👉 " --header "Select additional modules to enable now" \
    "🐳 Docker" \
    "🐘 PostgreSQL" \
    "🛤️  Ruby on Rails" \
    "⚛️  Next.js" \
    "🦀 Rust")

# 4. Final Review
echo -e "🚀 ${CYAN}Final Review:${NC}"
echo "   Target: $disk"
echo "   Keys:   $import_keys"
echo "   Stack:  $choice"
echo ""

if gum confirm "Start the background installation? (You can disconnect after this)"; then
    # Generate the state file
    STATE_FILE="/tmp/cafaye-initial-state.json"
    cp user/user-state.json.example "$STATE_FILE"
    
    # Update disk
    jq ".core.boot.grub_device = \"$disk\"" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    
    # Update keys
    if [[ "$import_keys" == "true" ]]; then
       keys_json=$(cat /root/.ssh/authorized_keys | jq -R . | jq -s .)
       jq ".core.authorized_keys = $keys_json" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    fi
    
    # Update modules
    [[ "$choice" == *"Docker"* ]] && jq ".dev_tools.docker = true" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    [[ "$choice" == *"PostgreSQL"* ]] && jq ".services.postgresql = true" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    [[ "$choice" == *"Rails"* ]] && jq ".frameworks.rails = true" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    [[ "$choice" == *"Next.js"* ]] && jq ".frameworks.nextjs = true" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"
    [[ "$choice" == *"Rust"* ]] && jq ".languages.rust = true" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp"

    echo "✅ Configuration generated at $STATE_FILE"
    exit 0
else
    echo "Installation cancelled."
    exit 1
fi
