{ config, pkgs, inputs, userState, ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./network.nix
    ./security.nix
  ];

  # Basic system settings that don't fit elsewhere
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set a default user (we'll make this more dynamic in later phases)
  users.users.cafaye = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "cafaye"; # To be changed on first run
    openssh.authorizedKeys.keys = userState.core.authorized_keys or [ ];
  };
}
