{ pkgs, inputs, userState, ... }:

let
  bootstrapMode = userState.core.security.bootstrap_mode or false;
in
{
  name = "core-security";
  nodes = {
    machine = {
      imports = [ 
        ../../../core/security
        ../../../core/network.nix
        ../../../core/hardware.nix
        ../../../core/user.nix
        ../../../core/sops.nix
        inputs.sops-nix.nixosModules.sops
      ];
      _module.args = { 
        inherit inputs;
        userState = userState // { core = userState.core // { security = { bootstrap_mode = true; }; }; };
      };
      
      # Mocks for test environment
      sops.validateSopsFiles = false;
      systemd.services.tailscale-autoconnect.enable = false;
      users.users.cafaye.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMY6S... test" ];
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
    '' else ''
    # Normal mode: fail2ban should be running
    machine.wait_for_unit("fail2ban.service")
    
    # Hardened Kernel Checks
    machine.succeed("sysctl kernel.kptr_restrict | grep '2'")
    machine.succeed("sysctl kernel.randomize_va_space | grep '2'")

    # Hardened SSH Checks
    machine.succeed("grep 'KexAlgorithms curve25519-sha256' /etc/ssh/sshd_config")
    ''}
  '';
}
