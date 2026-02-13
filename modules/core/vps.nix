{ config, pkgs, lib, userState, ... }:

let
  cfg = userState.core or {};
  autoShutdownEnabled = cfg.auto_shutdown or false;
  
  # Script to check for activity and shutdown
  sleepIdleScript = pkgs.writeShellScriptBin "caf-vps-sleepidle" ''
    # Configuration
    IDLE_TIMEOUT=3600 # 1 hour in seconds
    
    # Check for active SSH sessions
    # We ignore the current check session if possible
    SSH_SESSIONS=$(who | grep -v "cron" | wc -l)
    
    # Check for tmux sessions with activity? (optional)
    
    # If no sessions, check idle time
    if [ "$SSH_SESSIONS" -eq 0 ]; then
        echo "No active SSH sessions. Checking idle time..."
        # We use a file to track idle start
        IDLE_FILE="/tmp/cafaye_idle_start"
        if [ ! -f "$IDLE_FILE" ]; then
            date +%s > "$IDLE_FILE"
            exit 0
        fi
        
        START_TIME=$(cat "$IDLE_FILE")
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        
        if [ "$ELAPSED" -gt "$IDLE_TIMEOUT" ]; then
            echo "System idle for $ELAPSED seconds. Shutting down..."
            sudo shutdown -h now
        fi
    else
        # Activity detected, reset timer
        rm -f "/tmp/cafaye_idle_start"
    fi
  '';
in
{
  config = lib.mkIf (userState.core.vps or false) {
    home.packages = [
      sleepIdleScript
    ];

    # On NixOS, we would add a systemd service.
    # On non-NixOS, we can add a user systemd service or cron job.
    
    systemd.user.services.caf-vps-sleepidle = lib.mkIf autoShutdownEnabled {
      Unit = {
        Description = "Cafaye VPS Idle Sleep Service";
      };
      Service = {
        ExecStart = "${sleepIdleScript}/bin/caf-vps-sleepidle";
        Type = "oneshot";
      };
    };

    systemd.user.timers.caf-vps-sleepidle = lib.mkIf autoShutdownEnabled {
      Unit = {
        Description = "Cafaye VPS Idle Sleep Timer";
      };
      Timer = {
        OnCalendar = "*:0/5"; # Every 5 minutes
        Unit = "caf-vps-sleepidle.service";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
