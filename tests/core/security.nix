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
    # Bootstrap mode: SSH should be accessible on all interfaces
    machine.succeed("iptables -L | grep -q 'dpt:ssh'")
    '' else ''
    # Normal mode: fail2ban should be running
    machine.wait_for_unit("fail2ban.service")
    # Normal mode: SSH should only be accessible via Tailscale
    machine.succeed("iptables -L | grep -q 'tailscale0'")
    ''}
  '';
}
