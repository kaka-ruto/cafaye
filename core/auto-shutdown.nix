{ config, pkgs, userState, ... }:

let
  enabled = userState.core.auto_shutdown_enabled or false;
  idleMinutes = userState.core.auto_shutdown_idle_minutes or 60;
  
  autoShutdownScript = pkgs.writeShellScriptBin "cafaye-auto-shutdown" ''
    #!/usr/bin/env bash
    # Cafaye OS: Auto-shutdown service for cost optimization
    # Shuts down VPS after specified minutes of inactivity
    
    set -e
    
    IDLE_MINUTES=${toString idleMinutes}
    IDLE_SECONDS=$((IDLE_MINUTES * 60))
    CHECK_INTERVAL=60  # Check every minute
    
    log_info() {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] [cafaye-auto-shutdown] $*" | systemd-cat -t cafaye-auto-shutdown
    }
    
    get_last_activity() {
      local last_activity=0
      local current_time=$(date +%s)
      
      # Check active SSH sessions
      local ssh_activity=$(who | grep -E 'pts|tty' | awk '{print $3" "$4}' | sort -r | head -1)
      if [ -n "$ssh_activity" ]; then
        local ssh_timestamp=$(date -d "$ssh_activity" +%s 2>/dev/null || echo 0)
        if [ "$ssh_timestamp" -gt "$last_activity" ]; then
          last_activity=$ssh_timestamp
        fi
      fi
      
      # Check last command in bash/zsh history (if available)
      if [ -f /home/cafaye/.bash_history ] && [ -r /home/cafaye/.bash_history ]; then
        local bash_last=$(stat -c %Y /home/cafaye/.bash_history 2>/dev/null || echo 0)
        if [ "$bash_last" -gt "$last_activity" ]; then
          last_activity=$bash_last
        fi
      fi
      
      if [ -f /home/cafaye/.zsh_history ] && [ -r /home/cafaye/.zsh_history ]; then
        local zsh_last=$(stat -c %Y /home/cafaye/.zsh_history 2>/dev/null || echo 0)
        if [ "$zsh_last" -gt "$last_activity" ]; then
          last_activity=$zsh_last
        fi
      fi
      
      # Check CPU usage - if average load is above 0.5, consider it active
      local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
      if [ "$(echo "$load_avg > 0.5" | bc -l)" -eq 1 ]; then
        last_activity=$current_time
      fi
      
      # If no activity found, use current time
      if [ "$last_activity" -eq 0 ]; then
        last_activity=$current_time
      fi
      
      echo "$last_activity"
    }
    
    log_info "Auto-shutdown service started (idle timeout: $IDLE_MINUTES minutes)"
    
    while true; do
      sleep $CHECK_INTERVAL
      
      current_time=$(date +%s)
      last_activity=$(get_last_activity)
      idle_time=$((current_time - last_activity))
      
      remaining_seconds=$((IDLE_SECONDS - idle_time))
      remaining_minutes=$((remaining_seconds / 60))
      
      if [ "$idle_time" -ge "$IDLE_SECONDS" ]; then
        log_info "System has been idle for $IDLE_MINUTES minutes. Initiating shutdown..."
        
        # For GCP, we should use gcloud to stop the instance rather than poweroff
        # But since we may not have gcloud CLI, we'll use poweroff and let GCP handle it
        # Alternatively, users can configure a shutdown hook
        
        # Send warning to all logged-in users
        wall "CAFAYE AUTO-SHUTDOWN: System has been idle for $IDLE_MINUTES minutes. Shutting down in 60 seconds..." 2>/dev/null || true
        
        sleep 60
        
        # Check if anyone logged in during the warning period
        if [ -n "$(who | grep -E 'pts|tty')" ]; then
          log_info "User activity detected during shutdown warning. Aborting shutdown."
          continue
        fi
        
        log_info "Executing shutdown now"
        shutdown -h now
        exit 0
      else
        if [ $((remaining_minutes % 10)) -eq 0 ] && [ "$remaining_minutes" -lt 30 ] && [ "$remaining_minutes" -gt 0 ]; then
          log_info "System idle. Shutdown in $remaining_minutes minutes..."
        fi
      fi
    done
  '';
in
{
  systemd.services.cafaye-auto-shutdown = {
    enable = enabled;
    description = "Cafaye OS Auto-shutdown Service";
    after = [ "network.target" "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${autoShutdownScript}/bin/cafaye-auto-shutdown";
      Restart = "always";
      RestartSec = 10;
    };
    
    environment = {
      PATH = pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.bc pkgs.util-linux ];
    };
  };
  
  # Add a CLI command to manage auto-shutdown
  environment.systemPackages = pkgs.lib.optionals enabled [
    (pkgs.writeShellScriptBin "caf-auto-shutdown" ''
      #!/usr/bin/env bash
      # CLI tool to manage auto-shutdown settings
      
      case "$1" in
        status)
          if systemctl is-active --quiet cafaye-auto-shutdown; then
            echo "Auto-shutdown: ENABLED"
            systemctl status cafaye-auto-shutdown --no-pager | grep -E "(Active:|since)"
          else
            echo "Auto-shutdown: DISABLED"
          fi
          ;;
        enable)
          sudo systemctl enable --now cafaye-auto-shutdown
          echo "Auto-shutdown enabled"
          ;;
        disable)
          sudo systemctl disable --now cafaye-auto-shutdown
          echo "Auto-shutdown disabled"
          ;;
        timer)
          # Show time remaining until shutdown
          if systemctl is-active --quiet cafaye-auto-shutdown; then
            echo "Auto-shutdown is active (idle timeout: ${toString idleMinutes} minutes)"
          else
            echo "Auto-shutdown is not active"
          fi
          ;;
        *)
          echo "Usage: caf-auto-shutdown {status|enable|disable|timer}"
          echo ""
          echo "Commands:"
          echo "  status   Show current auto-shutdown status"
          echo "  enable   Enable auto-shutdown service"
          echo "  disable  Disable auto-shutdown service"
          echo "  timer    Show time remaining until shutdown"
          exit 1
          ;;
      esac
    '')
  ];
}
