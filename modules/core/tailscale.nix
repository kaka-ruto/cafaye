{ pkgs, userState, ... }:

{
  home.packages = with pkgs; [
    tailscale
  ];
}
