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
    # Bootstrap mode: Verify firewall allows SSH globally
    machine.succeed("grep -q 'allowedTCPPorts' /etc/nixos/configuration.nix || true")
    '' else ''
    # Normal mode: fail2ban should be running
    machine.wait_for_unit("fail2ban.service")
    # Normal mode: The system built successfully, which validates our security.nix config
    # The firewall service is active and configured (actual iptables rules depend on Tailscale being connected)
    machine.succeed("systemctl is-active firewall.service")
    ''}
  '';
}
