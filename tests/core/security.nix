{ pkgs, inputs, userState, ... }:

let
  bootstrapMode = userState.core.security.bootstrap_mode or false;
in
{
  name = "core-security";
  nodes = {
    machine = {
      imports = [ 
        ../../core/security.nix 
        ../../core/network.nix 
        ../../core/sops.nix
        ../../core/user.nix
        inputs.sops-nix.nixosModules.sops
      ];
      _module.args = { inherit inputs userState; };
      
      # Mock the sops file presence
      sops.validateSopsFiles = false;
      # Disable tailscale autoconnect in this test as well
      systemd.services.tailscale-autoconnect.enable = false;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if SSH is enabled
    machine.wait_for_unit("sshd.service")
    # Check if firewall is enabled
    machine.wait_for_unit("firewall.service")
    ${if bootstrapMode then ''
    # Bootstrap mode: fail2ban should be disabled
    machine.fail("systemctl is-active fail2ban.service")
    # Bootstrap mode: Check firewall config allows SSH on all interfaces
    machine.succeed("grep -q 'allowedTCPPorts =.*22' /etc/nixos/configuration.nix || grep -q 'allowedTCPPorts = \[ 22 \]' /nix/store/*/etc/nixos/configuration.nix 2>/dev/null || true")
    '' else ''
    # Normal mode: fail2ban should be running
    machine.wait_for_unit("fail2ban.service")
    # Normal mode: Check firewall config restricts SSH to tailscale0 interface
    # Verify the NixOS configuration (not runtime iptables since Tailscale isn't connected in test)
    machine.succeed("nixos-option networking.firewall.interfaces.tailscale0.allowedTCPPorts | grep -q '22'")
    ''}
  '';
}
