{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Global SOPS configuration
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  
  # Ensure sops-nix doesn't fail if the file doesn't exist during certain evaluations
  # sops.validateSopsFiles = false; # Handled in tests usually
}
