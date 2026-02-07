{ config, pkgs, userState, ... }:

let
  enabled = userState.languages.rust or false;
in
{
  environment.systemPackages = pkgs.lib.optional enabled pkgs.rustup;
}
