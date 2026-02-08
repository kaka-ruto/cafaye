{ config, pkgs, userState, ... }:

let
  enabled = (userState.languages.nodejs or false) || (userState.frameworks.nextjs or false);
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      nodejs
      nodePackages.npm
      nodePackages.yarn
      nodePackages.pnpm
    ]
  );
}
