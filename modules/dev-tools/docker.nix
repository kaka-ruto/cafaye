{ config, pkgs, userState, ... }:

let
  enabled = userState.dev_tools.docker or false;
in
{
  virtualisation.docker.enable = enabled;
  
  # Add the main user to the docker group if enabled
  users.users.cafaye.extraGroups = pkgs.lib.optional enabled "docker";
}
