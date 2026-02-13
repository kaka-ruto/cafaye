{ config, pkgs, lib, userState, ... }:

let
  raw = userState.services.mysql or false;
  enabled = if builtins.isAttrs raw then (raw.enable or false) else raw;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      mariadb.client # Provide the mysql client
    ];
  };
}
