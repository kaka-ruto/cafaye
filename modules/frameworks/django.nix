{ config, pkgs, userState, ... }:

let
  enabled = userState.frameworks.django or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      sqlite
      pkg-config
      gcc
    ]
  );
}
