{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.frameworks.rails or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      # Rails often needs these
      sqlite
      redis
      
      # Node and Yarn for asset compilation
      nodejs
      nodePackages.yarn
    ];
  };
}
