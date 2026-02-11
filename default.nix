{ inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./hardware/vps.nix
    ./core
    ./interface
    ./modules
    ./cli
  ];
}
