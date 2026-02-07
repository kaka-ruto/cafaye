{ config, pkgs, userState, ... }:

let
  enabled = userState.languages.go or false;
in
{
  environment.systemPackages = pkgs.lib.optional enabled pkgs.go;
}
