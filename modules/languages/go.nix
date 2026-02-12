{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.languages.go or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      go
    ];
  };
}
