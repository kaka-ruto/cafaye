{ config, pkgs, lib, userState, ... }:

let
  raw = userState.services.redis or false;
  enabled = if builtins.isAttrs raw then (raw.enable or false) else raw;
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
