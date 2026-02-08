#!/bin/bash
# Cafaye OS: SSH Key Management Helpers

collect_ssh_keys() {
  local ssh_keys=()
  
  echo "Add SSH keys for server access:"
  echo ""
  
  while true; do
    local choice=$(gum choose \
      "Add from SSH agent" \
      "Add from file" \
      "Paste manually" \
      "Done" \
      --header "SSH Keys")
    
    case "$choice" in
      "Add from SSH agent")
        if ssh-add -l 2>/dev/null | grep -q .; then
          local key_line=$(ssh-add -l | gum filter --header "Select SSH key")
          if [[ -n "$key_line" ]]; then
            local key_file=$(echo "$key_line" | awk '{print $3}')
            if [[ -f "$key_file" ]]; then
              ssh_keys+=("$(cat "$key_file")")
              echo "✓ Added key from SSH agent"
            fi
          fi
        else
          gum style --foreground 11 "No keys in SSH agent"
        fi
        ;;
      "Add from file")
        local key_file=$(gum file --file "$HOME/.ssh/")
        if [[ -n "$key_file" && -f "$key_file" ]]; then
          ssh_keys+=("$(cat "$key_file")")
          echo "✓ Added key from file"
        fi
        ;;
      "Paste manually")
        local key_content=$(gum input --placeholder "ssh-ed25519 AAAA... user@host" --header "Paste SSH public key")
        if [[ -n "$key_content" ]]; then
          ssh_keys+=("$key_content")
          echo "✓ Added key manually"
        fi
        ;;
      "Done")
        if [[ ${#ssh_keys[@]} -eq 0 ]]; then
          gum confirm "No SSH keys added. Continue anyway?" || continue
        fi
        break
        ;;
    esac
  done
  
  printf '%s\n' "${ssh_keys[@]}"
}

ssh_keys_to_json() {
  local ssh_keys=("$@")
  local json="["
  for i in "${!ssh_keys[@]}"; do
    if [[ $i -gt 0 ]]; then
      json+=","
    fi
    json+="\"${ssh_keys[$i]//\"/\\\"}\""
  done
  json+="]"
  echo "$json"
}
