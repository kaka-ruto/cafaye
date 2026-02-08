#!/bin/bash
# Cafaye OS: Tailscale Helpers

# Check if Tailscale is installed
is_tailscale_installed() {
  command -v tailscale &> /dev/null
}

# Check if already logged in to Tailscale
is_tailscale_logged_in() {
  if is_tailscale_installed; then
    tailscale status &> /dev/null
  else
    return 1
  fi
}

# Get Tailscale status
get_tailscale_status() {
  if ! is_tailscale_installed; then
    echo "not-installed"
  elif is_tailscale_logged_in; then
    echo "connected"
  else
    echo "not-connected"
  fi
}

# Generate Tailscale auth key URL
get_tailscale_auth_url() {
  echo "https://login.tailscale.com/admin/settings/keys"
}

# Setup Tailscale interactively
setup_tailscale() {
  log_step "Setting up Tailscale"
  
  if is_tailscale_logged_in; then
    log "Tailscale is already connected"
    TS_AUTH_KEY="already-connected"
    return 0
  fi
  
  echo ""
  gum style --foreground 212 "Tailscale provides secure access to your server from anywhere."
  echo ""
  echo "Benefits:"
  echo "• No open ports - SSH only via Tailscale"
  echo "• Access from any device (phone, laptop, tablet)"
  echo "• End-to-end encryption"
  echo "• Easy file sharing with Truebit"
  echo ""
  
  if ! gum confirm --affirmative="Set up Tailscale" --negative="Skip" "Configure Tailscale during installation?"; then
    log "Tailscale setup skipped"
    TS_AUTH_KEY=""
    return 0
  fi
  
  echo ""
  echo "You have two options:"
  echo ""
  
  local choice=$(gum choose \
    "I have an existing Tailscale account" \
    "I need to create a Tailscale account" \
    --header "Tailscale Setup")
  
  case "$choice" in
    "I have an existing Tailscale account")
      echo ""
      echo "1. Open: $(get_tailscale_auth_url)"
      echo "2. Click 'Generate auth key'"
      echo "3. Copy the key (starts with 'tskey-auth-')"
      echo ""
      
      if command -v xdg-open &> /dev/null; then
        xdg-open "$(get_tailscale_auth_url)" 2>/dev/null || true
      elif command -v open &> /dev/null; then
        open "$(get_tailscale_auth_url)" 2>/dev/null || true
      fi
      
      if gum confirm "Opened Tailscale admin panel?"; then
        TS_AUTH_KEY=$(gum input --password --placeholder "tskey-auth-..." --header "Paste your Tailscale auth key")
      else
        TS_AUTH_KEY=$(gum input --password --placeholder "tskey-auth-..." --header "Paste your Tailscale auth key")
      fi
      ;;
      
    "I need to create a Tailscale account")
      echo ""
      echo "1. Sign up at https://tailscale.com"
      echo "2. Create your network"
      echo "3. Generate an auth key at: $(get_tailscale_auth_url)"
      echo ""
      
      if command -v xdg-open &> /dev/null; then
        xdg-open "https://tailscale.com" 2>/dev/null || true
      elif command -v open &> /dev/null; then
        open "https://tailscale.com" 2>/dev/null || true
      fi
      
      if gum confirm --affirmative="Continue" --negative="Skip" "Create Tailscale account now?"; then
        echo ""
        TS_AUTH_KEY=$(gum input --password --placeholder "tskey-auth-..." --header "Paste your Tailscale auth key after creating account")
      else
        gum style --foreground 11 "Skipping Tailscale setup"
        echo "You can configure Tailscale later with: sudo tailscale up"
        TS_AUTH_KEY=""
      fi
      ;;
  esac
  
  if [[ -n "$TS_AUTH_KEY" ]]; then
    log "Tailscale auth key configured"
  fi
}

# Validate Tailscale auth key format
validate_tailscale_key() {
  local key="$1"
  
  if [[ -z "$key" ]]; then
    return 1
  fi
  
  # Tailscale auth keys start with "tskey-auth-" and are at least 30 chars
  if [[ ${#key} -lt 30 ]]; then
    return 1
  fi
  
  return 0
}

# Get Tailscale IP if connected
get_tailscale_ip() {
  if is_tailscale_logged_in; then
    tailscale ip -4 2>/dev/null || echo ""
  fi
}
