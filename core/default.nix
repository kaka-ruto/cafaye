{ config, pkgs, userState, ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./network.nix
    ./security
    ./sops.nix
    ./user.nix
    ./auto-shutdown.nix
  ];

  # Basic system settings that don't fit elsewhere
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
