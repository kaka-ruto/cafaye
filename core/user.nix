{ config, pkgs, userState, ... }:

{
  # Central user definition for Cafaye OS
  users.users.cafaye = {
    isNormalUser = true;
    group = "cafaye";
    extraGroups = [ "wheel" "networkmanager" "nix-users" ];
    initialPassword = "cafaye"; # To be changed on first run
    openssh.authorizedKeys.keys = userState.core.authorized_keys or [ ];
  };

  users.groups.cafaye = {};

  # Allow the user to control nix
  nix.settings.trusted-users = [ "root" "cafaye" ];
}
