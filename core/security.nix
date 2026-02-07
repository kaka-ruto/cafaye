{ config, pkgs, ... }:

{
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

  # Fail2ban for basic brute force protection
  services.fail2ban.enable = true;
}
