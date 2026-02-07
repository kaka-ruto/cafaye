{ pkgs, inputs, userState, ... }:

{
  name = "core-security";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ ../../core/security.nix ../../core/network.nix ];
      _module.args = { inherit inputs userState; };
      # Mock the sops file presence if needed, or skip sops for this test
      sops.validateSopsFiles = false;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if SSH is enabled
    machine.wait_for_unit("sshd.service")
    # Check if firewall is enabled
    machine.succeed("systemctl is-active nftables || systemctl is-active iptables")
    # Check if fail2ban is running
    machine.wait_for_unit("fail2ban.service")
  '';
}
