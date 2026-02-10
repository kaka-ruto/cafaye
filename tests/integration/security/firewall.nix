{ pkgs, inputs, userState, ... }:

{
  name = "core-security-firewall";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../../core/security/firewall.nix 
        ../../../core/hardware.nix
      ];
      _module.args = { 
        inherit inputs;
        userState = userState // { core = userState.core // { security = { bootstrap_mode = false; }; }; };
      };
      
      # Mock the interface tailscale0 so the firewall service doesn't fail
      boot.kernelModules = [ "dummy" ];
      systemd.services.mock-tailscale-if = {
        description = "Mock Tailscale Interface";
        before = [ "network-pre.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.iproute2}/bin/ip link add tailscale0 type dummy || true
          ${pkgs.iproute2}/bin/ip link set tailscale0 up
        '';
      };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("firewall.service")
    # Verify fail2ban is active (normal mode)
    machine.wait_for_unit("fail2ban.service")
    machine.succeed("systemctl is-active fail2ban.service")
  '';
}
