{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Enable the firewall
  networking.firewall.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    openFirewall = false; # We will open it specifically for Tailscale
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Zero-Trust: only allow SSH via Tailscale
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];

  # SOPS configuration
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  
  # Fail2ban for basic brute force protection on exposed SSH (if any)
  services.fail2ban.enable = true;
}
