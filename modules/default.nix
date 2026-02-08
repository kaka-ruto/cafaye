{ config, pkgs, userState, ... }:

{
  imports = [
    ./languages
    ./services
    ./frameworks
    ./editors
    ./dev-tools/docker.nix
  ];
}
