{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.services.redis or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      redis
    ];
    
    # On Linux/NixOS, we could potentially manage a user-level redis service 
    # if the system allows it. For now, we assume standard dev patterns.
  };
}
