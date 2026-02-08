#!/bin/bash
# Cafaye OS: Network & Connectivity Helpers

# Test SSH connectivity
test_ssh_connection() {
  local host=$1
  local port=${2:-22}
  local timeout=${3:-10}
  
  log "Testing SSH connection to $host:$port..."
  
  if timeout $timeout bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
    log_success "SSH port is reachable"
    return 0
  else
    log_error "Cannot connect to SSH at $host:$port"
    return 1
  fi
}

# Test SSH authentication
test_ssh_auth() {
  local host=$1
  local user=$2
  local port=${3:-22}
  
  log "Testing SSH authentication as $user@$host..."
  
  if ssh -o BatchMode=yes \
         -o ConnectTimeout=5 \
         -o StrictHostKeyChecking=accept-new \
         -p $port "$user@$host" "echo 'SSH auth successful'" 2>/dev/null; then
    log_success "SSH authentication successful"
    return 0
  else
    log_error "SSH authentication failed"
    return 1
  fi
}

# Test if target is already running NixOS
detect_existing_os() {
  local host=$1
  local user=$2
  local port=${3:-22}
  
  log "Detecting existing OS on $host..."
  
  local os_info=$(ssh -o BatchMode=yes \
                    -o ConnectTimeout=5 \
                    -p $port "$user@$host" \
                    "cat /etc/os-release 2>/dev/null | head -5" 2>/dev/null)
  
  if echo "$os_info" | grep -qi "nixos"; then
    echo "nixos"
  elif echo "$os_info" | grep -qi "ubuntu\|debian\|centos\|fedora\|rhel"; then
    echo "linux"
  else
    echo "unknown"
  fi
}

# Check disk availability
check_disk_space() {
  local host=$1
  local user=$2
  local port=${3:-22}
  
  log "Checking disk space on $host..."
  
  local disk_info=$(ssh -o BatchMode=yes \
                      -o ConnectTimeout=5 \
                      -p $port "$user@$host" \
                      "df -h / | tail -1" 2>/dev/null)
  
  if [[ -n "$disk_info" ]]; then
    log "Disk info: $disk_info"
    echo "$disk_info"
  fi
}

# Validate target is suitable for installation
validate_target() {
  local host=$1
  local user=$2
  local port=${3:-22}
  
  local os=$(detect_existing_os "$host" "$user" "$port")
  
  if [[ "$os" == "nixos" ]]; then
    gum style --foreground 11 "Target is already running NixOS!"
    if ! gum confirm "Continue anyway?"; then
      exit 1
    fi
  elif [[ "$os" == "unknown" ]]; then
    gum style --foreground 11 "Could not detect existing OS"
    if ! gum confirm "Proceed with installation anyway?"; then
      exit 1
    fi
  fi
}
