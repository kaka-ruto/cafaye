{ config, pkgs, lib, userState, ... }:

let
  raw = userState.services.postgresql or false;
  enabled = if builtins.isAttrs raw then (raw.enable or false) else raw;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      postgresql_16 # Standard stable
      # Usually on dev machine we just need the client + lib
      # Server is often handled by Docker or system.
    ];
    
    # Optional: Set PG environment variables
    home.sessionVariables = {
      PGHOST = "localhost";
      PGUSER = config.home.username;
    };
  };
}
