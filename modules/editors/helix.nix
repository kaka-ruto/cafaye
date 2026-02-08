{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.helix or false;
in
{
  environment.systemPackages = pkgs.lib.optional enabled pkgs.helix;
}
