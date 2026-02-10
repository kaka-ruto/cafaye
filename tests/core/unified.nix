{ pkgs, inputs, userState, ... }:

# Unified Core Test - Tests all core modules in ONE VM boot
# This replaces: core-boot, core-network, core-security
{
  name = "core-unified";
  nodes = {
    machine = { ... }:
      {
        imports = [
          ../../core/boot.nix
          ../../core/hardware.nix
          ../../core/network.nix
          ../../core/security
          ../../core/sops.nix
          ../../core/user.nix
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = { inherit inputs userState; };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # === CORE-BOOT TESTS ===
    # Check if ZRAM is enabled
    machine.succeed("zramctl")
    # Check kernel version
    machine.succeed("uname -r")
    
    # === CORE-NETWORK TESTS ===
    # Check if network is up
    machine.succeed("ip link show")
    machine.succeed("ping -c 1 127.0.0.1")
    
    # === CORE-SECURITY TESTS ===
    # Check if SSH is enabled
    machine.wait_for_unit("sshd.service")
    # Check if firewall is enabled
    machine.wait_for_unit("firewall.service")
    
    ${if (userState.core.security.bootstrap_mode or false) then ''
      # Bootstrap mode: fail2ban should be disabled
      machine.fail("systemctl is-active fail2ban.service")
    '' else ''
      # Normal mode: fail2ban should be running
      machine.wait_for_unit("fail2ban.service")
      # Normal mode: Verify firewall is active (actual iptables rules depend on Tailscale)
      machine.succeed("systemctl is-active firewall.service")
    ''}
  '';
}
