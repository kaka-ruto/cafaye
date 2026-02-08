{ config, pkgs, userState, ... }:

{
  imports = [
    ./languages
    ./services
    ./frameworks
    ./dev-tools/docker.nix
  ];
}
