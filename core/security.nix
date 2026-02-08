{ config, pkgs, userState, ... }:

let
  bootstrapMode = userState.core.security.bootstrap_mode or false;
in
{
  # Enable the firewall
  networking.firewall = {
    enable = true;
  } // (if bootstrapMode then {
    # Bootstrap mode: Open SSH to all interfaces for initial setup
    allowedTCPPorts = [ 22 ];
  } else {
    # Normal mode: Zero-trust, only via Tailscale
    interfaces."tailscale0".allowedTCPPorts = [ 22 ];
  });

  # Enable SSH
  services.openssh = {
    enable = true;
    openFirewall = false; # We control firewall rules manually
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Fail2ban for basic brute force protection (only in normal mode)
  services.fail2ban.enable = !bootstrapMode;
}
