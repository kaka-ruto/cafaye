{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.frameworks.nextjs or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      nodejs_22
      corepack # yarn/pnpm
    ];
  };
}
