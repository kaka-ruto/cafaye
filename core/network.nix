{ config, pkgs, userState, ... }:

{
  networking.hostName = "cafaye";
  
  # Use NetworkManager for easier network configuration
  networking.networkmanager.enable = true;

  # Enable Tailscale
  services.tailscale.enable = userState.core.tailscale_enabled or true;

  # DNS settings (using Cloudflare as a sensible default)
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  
  # Wait for online status before continuing with some services
  systemd.services.NetworkManager-wait-online.enable = false; # Often causes issues on VPS
}
