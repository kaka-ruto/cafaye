#!/usr/bin/env bash
# Cafaye OS: Installer Wizard (TUI)
# Collects all user preferences before starting the background installation.

set -e

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure dependencies are found (especially in minimal/test environments)
export PATH="/tmp:/usr/local/bin:/usr/bin:/bin:$PATH"

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
    exit 1
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

# 3. Development Environment
echo -e "🛠️  ${CYAN}Development Stack:${NC}"
choices=$(gum choose --no-limit --header "Select tools & frameworks to pre-install:" \
    "🐳 Docker" \
    "🛤️  Ruby on Rails" \
    "🟢 Node.js" \
    "🐬 MySQL" \
    "🐘 PostgreSQL" \
    "🦊 Redis") || exit 1

echo "   Selected: $(echo "$choices" | tr '\n' ', ' | sed 's/, $//')"
echo ""

# 4. Final Review
echo -e "🚀 ${CYAN}Final Review:${NC}"
echo "   Target: $disk"
echo "   Keys:   $import_keys"
echo "   Stack:  $(echo "$choices" | tr '\n' ' ')"
echo ""

if gum confirm "Start the background installation? (You can disconnect after this)"; then
    # Generate the state file
    STATE_FILE="${STATE_FILE:-/tmp/cafaye-initial-state.json}"
    cp user/user-state.json.example "$STATE_FILE" || { echo "Failed to copy example state"; exit 1; }
    
    # Update disk
    echo "Updating disk..."
    jq ".core.boot.grub_device = \"$disk\"" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp" || { echo "Failed to update disk"; exit 1; }
    
    # Update tools based on choices
    echo "Configuring stack..."
    [[ "$choices" == *"Docker"* ]] && jq ".dev_tools.docker = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    [[ "$choices" == *"Ruby on Rails"* ]] && jq ".frameworks.rails = true | .languages.ruby = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    [[ "$choices" == *"Node.js"* ]] && jq ".languages.nodejs = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    [[ "$choices" == *"MySQL"* ]] && jq ".services.mysql = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    [[ "$choices" == *"PostgreSQL"* ]] && jq ".services.postgresql = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    [[ "$choices" == *"Redis"* ]] && jq ".services.redis = true" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    # Update keys
    if [[ "$import_keys" == "true" ]]; then
       echo "Updating keys..."
       keys_json=$(cat /root/.ssh/authorized_keys | jq -R . | jq -s .)
       jq ".core.authorized_keys = $keys_json" "$STATE_FILE" > "$STATE_FILE.tmp" && cp "$STATE_FILE.tmp" "$STATE_FILE" && rm "$STATE_FILE.tmp" || { echo "Failed to update keys"; exit 1; }
    fi

    echo "✅ Configuration generated at $STATE_FILE"
    exit 0
else
    echo "Installation cancelled."
    exit 1
fi
