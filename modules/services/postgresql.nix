{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.services.postgresql or false;
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
