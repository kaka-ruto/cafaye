{ config, pkgs, userState, ... }:

{
  # Enable SSH with hardened defaults
  services.openssh = {
    enable = true;
    openFirewall = false; # We control firewall rules manually
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      # Hardened algorithms
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
    };
  };
}
