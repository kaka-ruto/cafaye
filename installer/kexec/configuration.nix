{ config, pkgs, modulesPath, disko, ... }:

{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
    ./installer-module.nix
  ];

  # Add disko and other tools to system packages just in case
  environment.systemPackages = [ 
    disko.packages.x86_64-linux.disko 
  ];
}
