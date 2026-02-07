{ config, pkgs, ... }:

{
  # Global SOPS configuration
  # Note: The 'sops-nix' module must be imported by the caller (flake.nix or tests)
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
