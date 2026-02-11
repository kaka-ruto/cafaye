{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # Default location for the secrets file
    defaultSopsFile = ../../secrets/fleet.yaml;
    
    # Use SSH keys for decryption (converted to age keys automatically by sops-nix)
    age.sshKeyPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
      "${config.home.homeDirectory}/.ssh/id_rsa"
    ];
    
    # This is where the decrypted secrets will be symlinked
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
  };

  home.packages = with pkgs; [
    sops
    age
    ssh-to-age
  ];
}
