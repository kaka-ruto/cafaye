{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.vscode_server or false;
in
{
  # VS Code Server is typically a set of scripts and binaries.
  # We facilitate its use by providing nix-ld and necessary libraries.
  # The actual server is often started via the local VS Code "Remote SSH" extension.
  
  # However, for a fully managed "Code Server" (browser-based), 
  # we would use the 'code-server' package.
  
  environment.systemPackages = pkgs.lib.optionals enabled [
    pkgs.code-server
  ];

  systemd.services.code-server = pkgs.lib.mkIf enabled {
    description = "VS Code Server";
    after = [ "network.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "cafaye";
      ExecStart = "${pkgs.code-server}/bin/code-server --bind-addr 127.0.0.1:8080 --auth none";
      Restart = "always";
    };
  };
  
  # Note: To access via Tailscale, we would typically use a reverse proxy 
  # or bind to the Tailscale IP. For now, we bind to localhost and assume SSH tunneling 
  # or a future Caddy/Nginx phase will expose it via Tailscale.
}
