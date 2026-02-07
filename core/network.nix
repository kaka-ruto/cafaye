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
  systemd.services.NetworkManager-wait-online.enable = false;

  # Tailscale auto-join service
  sops.secrets.tailscale_auth_key = { };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscaled.service" ];
    wants = [ "network-pre.target" "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      # Wait for tailscaled to settle
      sleep 2
      
      # Check if we are already authenticated
      status=$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)
      if [ "$status" = "Running" ]; then
        echo "Tailscale is already running."
        exit 0
      fi

      # Authenticate with auth key
      ${pkgs.tailscale}/bin/tailscale up --authkey $(cat ${config.sops.secrets.tailscale_auth_key.path})
    '';
  };
}
