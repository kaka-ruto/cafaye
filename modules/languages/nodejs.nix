{ config, pkgs, lib, userState, ... }:

let
  enabled = (userState.languages.nodejs or false) || (userState.frameworks.nextjs or false);
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      nodejs_22 # Latest LTS
      corepack  # For yarn/pnpm management
    ];
  };
}
