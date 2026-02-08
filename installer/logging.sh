#!/bin/bash
# Cafaye OS: Logging Helpers

export CAFAYE_INSTALL_LOG="/tmp/cafaye-install.log"
export CAFAYE_START_TIME

start_log() {
  touch "$CAFAYE_INSTALL_LOG"
  chmod 666 "$CAFAYE_INSTALL_LOG"
  CAFAYE_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo "=== Cafaye Installation Started: $CAFAYE_START_TIME ===" >>"$CAFAYE_INSTALL_LOG"
}

log() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $message" >>"$CAFAYE_INSTALL_LOG"
  echo "$message"
}

log_step() {
  local step="$1"
  log "→ $step"
}

log_success() {
  log "✓ $1"
}

log_error() {
  log "✗ $1"
}

stop_log() {
  local exit_code=$?
  local end_time=$(date '+%Y-%m-%d %H:%M:%S')
  
  if [[ -n "$CAFAYE_START_TIME" ]]; then
    local start_epoch=$(date -d "$CAFAYE_START_TIME" +%s)
    local end_epoch=$(date -d "$end_time" +%s)
    local duration=$((end_epoch - start_epoch))
    local mins=$((duration / 60))
    local secs=$((duration % 60))
    
    echo "" >>"$CAFAYE_INSTALL_LOG"
    echo "=== Installation Duration: ${mins}m ${secs}s ===" >>"$CAFAYE_INSTALL_LOG"
  fi
  
  if [[ $exit_code -ne 0 ]]; then
    echo "=== Installation FAILED ===" >>"$CAFAYE_INSTALL_LOG"
  else
    echo "=== Installation Completed ===" >>"$CAFAYE_INSTALL_LOG"
  fi
  
  return $exit_code
}
