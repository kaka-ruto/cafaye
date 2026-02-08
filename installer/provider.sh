#!/bin/bash
# Cafaye OS: Provider Detection Helpers

detect_provider() {
  local ip=$1
  local provider="unknown"
  
  # Hetzner Cloud (Germany, Finland, US)
  if [[ ${ip:0:4} == "5.75" || ${ip:0:4} == "5.78" || ${ip:0:4} == "5.161" || ${ip:0:4} == "65.109" ]]; then
    provider="hetzner"
  # DigitalOcean (US, Europe, Singapore, India)
  elif [[ ${ip:0:4} == "65.1" || ${ip:0:4} == "64.2" || ${ip:0:4} == "68.183" || ${ip:0:4} == "157.245" ]]; then
    provider="digitalocean"
  # AWS
  elif [[ ${ip:0:4} == "3.80" || ${ip:0:4} == "3.84" || ${ip:0:4} == "52.2" || ${ip:0:4} == "52.21" ]]; then
    provider="aws"
  # Vultr
  elif [[ ${ip:0:4} == "45.5" || ${ip:0:4} == "45.8" || ${ip:0:4} == "66.4" ]]; then
    provider="vultr"
  # GCP
  elif [[ ${ip:0:4} == "34.1" || ${ip:0:4} == "35.1" || ${ip:0:4} == "35.2" ]]; then
    provider="gcp"
  fi
  
  echo "$provider"
}

get_disk_device() {
  local provider=$1
  
  case "$provider" in
    "hetzner")
      echo "/dev/sda"
      ;;
    "aws")
      echo "/dev/nvme0n1"
      ;;
    "digitalocean"|"vultr"|"gcp"|"unknown"|*)
      echo "/dev/vda"
      ;;
  esac
}

get_provider_display_name() {
  local provider=$1
  
  case "$provider" in
    "hetzner")
      echo "Hetzner Cloud"
      ;;
    "digitalocean")
      echo "DigitalOcean"
      ;;
    "aws")
      echo "AWS EC2"
      ;;
    "vultr")
      echo "Vultr"
      ;;
    "gcp")
      echo "Google Cloud"
      ;;
    *)
      echo "Unknown Provider"
      ;;
  esac
}
