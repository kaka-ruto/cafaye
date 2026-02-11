{ pkgs, lib, userState, ... }:

{
  home.packages = lib.mkIf (userState.core.tailscale.enabled or false) [
    pkgs.tailscale
  ];
}
