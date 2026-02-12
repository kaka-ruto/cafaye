{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.services.mysql or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      mariadb.client # Provide the mysql client
    ];
  };
}
